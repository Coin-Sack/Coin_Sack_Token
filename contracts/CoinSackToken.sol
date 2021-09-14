/*
    ___           _              __             ___               
     | |_   _    /   _  o ._    (_   _.  _ |     |  _  |   _  ._  
     | | | (/_   \_ (_) | | |   __) (_| (_ |<    | (_) |< (/_ | |  

*/



// SPDX-License-Identifier: MIT
pragma solidity ^0.8.7;



import './contexts/Manageable.sol';

import './interfaces/IBEP20.sol';
import './interfaces/IPancakeFactory.sol';
import './interfaces/IPancakePair.sol';
import './interfaces/IPancakeRouter02.sol';

import './libraries/SackMath.sol';



contract CoinSackToken is IBEP20, Manageable {
    
    using SackMath for uint256;


    uint256 private constant MAX = ~uint256(0);


    string private _name = "Coin Sack";
    string private _symbol = "CS";
    uint8 private _decimals = 3;
    uint256 private _tTotal = 100000000000 * 10**_decimals;


    mapping (address => uint256) private _tOwned;
    mapping (address => mapping (address => uint256)) private _tAllowances;


    bool public _areLimitsEnabled = false;
    mapping (address => bool) private _isExcludedFromLimits;
    uint256 public _maxTransferAmount = _tTotal.mul(10).div(100);


    mapping (address => bool) private _isExcludedFromReflections;
    mapping (address => uint256) private _rOwned;
    address[] private _excludedFromReflections;
    uint256 private _rTotal = (MAX - (MAX % _tTotal));


    bool public _areFeesEnabled = false;
    mapping (address => bool) private _isExcludedFromFees;
    uint256 public _buyFeeManagementPercentage = 3;
    uint256 public _buyFeeReservePercentage = 8;
    uint256 public _buyFeeReflectionPercentage = 4;

    uint256 public _sellFeeManagementPercentage = 5;
    uint256 public _sellFeeReservePercentage = 10;
    uint256 public _sellFeeReflectionPercentage = 5;

    uint256 public _buyFeeTotalPercentage = _buyFeeManagementPercentage + _buyFeeReservePercentage + _buyFeeReflectionPercentage;
    uint256 public _sellFeeTotalPercentage = _sellFeeManagementPercentage + _sellFeeReservePercentage + _sellFeeReflectionPercentage;


    IPancakeRouter02 public _pancakeRouter;
    IPancakePair public _pancakePair;


    address[] public _managementFeesRecievers;
    mapping (address => bool) private _isManagementFeesReciever;
    uint256 public _maxNumberManagementFeesRecievers = 5;


    bool public _isAutoFeeLiquifyEnabled = false;
    uint256 public _minPendingFeesForAutoLiquify = 55000000 * 10**_decimals;
    uint256 public _autoLiquifyFactor = 10;
    bool private _isInternallySwapping = false;
    uint256 private _amountManagementFeesPendingLiquidation = 0;
    uint256 private _amountReserveFeesPendingLiquidation = 0;
    uint256 public _amountTotalFeesPendingLiquidation =  _amountManagementFeesPendingLiquidation + _amountReserveFeesPendingLiquidation;


    address public _deadAddress = 0x000000000000000000000000000000000000dEaD;
    
    bool public _isAutoBuybackEnabled = false;
    uint256 public _minReserveETHForAutoBuyback = 1 * 10**18 / 2;
    uint256 public _autoBuybackFactor = 2;

    bool public _isAutoReinjectEnabled = false;
    uint256 public _minReserveETHForAutoReinject = 125 * 10**18;
    uint256 public _autoReinjectFactor = 1;



    constructor(address pancakeRouter) {
        _pancakeRouter = IPancakeRouter02(pancakeRouter);
        _pancakePair = IPancakePair(IPancakeFactory(_pancakeRouter.factory()).createPair(_contextAddress(), _pancakeRouter.WETH()));

        _isExcludedFromReflections[address(_pancakePair)] = true;
        _excludedFromReflections.push(address(_pancakePair));

        _isExcludedFromFees[_contextAddress()] = true;
        _isExcludedFromLimits[_contextAddress()] = true;
        _isExcludedFromReflections[_contextAddress()] = true;
        _excludedFromReflections.push(_contextAddress());

        _isExcludedFromFees[_deadAddress] = true;
        _isExcludedFromLimits[_deadAddress] = true;
        _isExcludedFromReflections[_deadAddress] = true;
        _excludedFromReflections.push(_deadAddress);

        _isExcludedFromFees[_msgSender()] = true;
        _isExcludedFromLimits[_msgSender()] = true;
        _isExcludedFromReflections[_msgSender()] = true;
        _excludedFromReflections.push(_msgSender());

        _rOwned[_msgSender()] = _rTotal;
        _tOwned[_msgSender()] = _tTotal;

        emit MintTokens(_tTotal);
        emit Transfer(address(0), _msgSender(), _tTotal);
    }



    function name() public override view returns (string memory) {
        return _name;
    }

    function symbol() public override view returns (string memory) {
        return _symbol;
    }

    function decimals() public override view returns (uint8) {
        return _decimals;
    }

    function totalSupply() public override view returns (uint256) {
        return _tTotal;
    }

    function getOwner() public view returns (address) {
        return executiveManager();
    }

    function balanceOf(address account) public override view returns (uint256) {
        return _isExcludedFromReflections[account] ? _tOwned[account] : _rOwned[account].div(_getCurrentReflectionRate());
    }

    function transfer(address to, uint256 tAmount) public override returns (bool) {
        _transfer(_msgSender(), to, tAmount);
        return true;
    }

    function allowance(address owner, address spender) public override view returns (uint256) {
        return _tAllowances[owner][spender];
    }

    function approve(address spender, uint256 tAmount) public override returns (bool) {
        _approve(_msgSender(), spender, tAmount);
        return true;
    }

    function transferFrom(address owner, address to, uint256 amount) public override returns (bool) {
        _transfer(owner, to, amount);
        _approve(owner, _msgSender(), _tAllowances[owner][_msgSender()].sub(amount, "transfer amount exceeds spender's allowance"));
        return true;
    }

    function increaseAllowance(address spender, uint256 amount) public returns (bool) {
        _approve(_msgSender(), spender, _tAllowances[_msgSender()][spender].add(amount));
        return true;
    }

    function decreaseAllowance(address spender, uint256 amount) public returns (bool) {
        if(amount <= _tAllowances[_msgSender()][spender]){
            _approve(_msgSender(), spender, _tAllowances[_msgSender()][spender].sub(amount));
        } else {
            _approve(_msgSender(), spender, 0);
        }
        return true;
    }


    function isExcludedFromReflections(address account) public view returns (bool) {
        return _isExcludedFromReflections[account];
    }

    function isExcludedFromFees(address account) public view returns (bool) {
        return _isExcludedFromFees[account];
    }

    function isExcludedFromLimits(address account) public view returns (bool) {
        return _isExcludedFromLimits[account];
    }


    function _approve(address owner, address spender, uint256 tAmount) private {
        require(owner != address(0), "cannot approve allwoance from the zero address");
        require(spender != address(0), "cannot approve allwoance to the zero address");

        _tAllowances[owner][spender] = tAmount;
        emit Approval(owner, spender, tAmount);
    }

    function _transfer(address from, address to, uint256 tAmount) private {
        require(from != address(0) && to != address(0), "cannot transfer tokens from or to the zero address");
        require(tAmount <= _maxTransferAmount || !_areLimitsEnabled || _isExcludedFromLimits[from] || _isExcludedFromLimits[to], "transfer amount exceeds transaction limit");

        if(tAmount == 0) {
            return;
        }

        uint256 fromAccountTBalance = balanceOf(from);
        require(fromAccountTBalance >= tAmount, "insufficent from account token balance");

        uint256 currentReflectionRate = _getCurrentReflectionRate();

        uint256 tManagementFeeAmount = 0;
        uint256 tReserveFeeAmount = 0;
        uint256 tReflectionsFeeAmount = 0;
        if(_areFeesEnabled && !(_isExcludedFromFees[from] || _isExcludedFromFees[to])) {
            if(from == address(_pancakePair)){
                tManagementFeeAmount = tAmount.mul(_buyFeeManagementPercentage).div(100);
                tReserveFeeAmount = tAmount.mul(_buyFeeReservePercentage).div(100);
                tReflectionsFeeAmount = tAmount.mul(_buyFeeReflectionPercentage).div(100);
            } else if (to == address(_pancakePair)){
                tManagementFeeAmount = tAmount.mul(_sellFeeManagementPercentage).div(100);
                tReserveFeeAmount = tAmount.mul(_sellFeeReservePercentage).div(100);
                tReflectionsFeeAmount = tAmount.mul(_sellFeeReflectionPercentage).div(100);
            }
        }

        uint256 tTransferAmount = tAmount.sub(tManagementFeeAmount).sub(tReserveFeeAmount).sub(tReflectionsFeeAmount);
        uint256 rAmount = tAmount.mul(currentReflectionRate);
        uint256 rTransferAmount = tTransferAmount.mul(currentReflectionRate);

        if(to == address(_pancakePair) && !_isInternallySwapping){
            if(_isAutoFeeLiquifyEnabled && _amountTotalFeesPendingLiquidation >= _minPendingFeesForAutoLiquify) {
                _liquidateFees(_autoLiquifyFactor);
            }

            if(_isAutoBuybackEnabled && _contextAddress().balance >= _minReserveETHForAutoBuyback){
                _buybackTokens(_autoBuybackFactor);
            }

            if(_isAutoReinjectEnabled && _contextAddress().balance >= _minReserveETHForAutoReinject && balanceOf(_deadAddress) != 0){
                _reinjectTokens(_autoReinjectFactor);
            }
        }

        if(_areFeesEnabled && !(_isExcludedFromFees[to] || _isExcludedFromFees[from])){
            _tOwned[_contextAddress()] = _tOwned[_contextAddress()].add(tManagementFeeAmount + tReserveFeeAmount);
            _rOwned[_contextAddress()] = _rOwned[_contextAddress()].add((tManagementFeeAmount + tReserveFeeAmount).mul(currentReflectionRate));

            emit Transfer(from, _contextAddress(), tManagementFeeAmount + tReserveFeeAmount);

            _amountManagementFeesPendingLiquidation = _amountManagementFeesPendingLiquidation.add(tManagementFeeAmount);
            _amountReserveFeesPendingLiquidation = _amountReserveFeesPendingLiquidation.add(tReserveFeeAmount);
            _amountTotalFeesPendingLiquidation = _amountManagementFeesPendingLiquidation + _amountReserveFeesPendingLiquidation;

            _rTotal = _rTotal.sub(tReflectionsFeeAmount.mul(currentReflectionRate));
            emit ReflectTokens(tReflectionsFeeAmount);
        }
   
        if(_isExcludedFromReflections[from] && !_isExcludedFromReflections[to]){
            _tOwned[from] = _tOwned[from].sub(tAmount);
            _rOwned[from] = _rOwned[from].sub(rAmount);
            _rOwned[to] = _rOwned[to].add(rTransferAmount);
        } else if(!_isExcludedFromReflections[from] && _isExcludedFromReflections[to]) {
            _rOwned[from] = _rOwned[from].sub(rAmount);
            _tOwned[to] = _tOwned[to].add(tTransferAmount);
            _rOwned[to] = _rOwned[to].add(rTransferAmount);
        } else if(_isExcludedFromReflections[from] && _isExcludedFromReflections[to]) {
            _tOwned[from] = _tOwned[from].sub(tAmount);
            _rOwned[from] = _rOwned[from].sub(rAmount);
            _tOwned[to] = _tOwned[to].add(tTransferAmount);
            _rOwned[to] = _rOwned[to].add(rTransferAmount);
        } else {
            _rOwned[from] = _rOwned[from].sub(rAmount);
            _rOwned[to] = _rOwned[to].add(rTransferAmount);
        }

        emit Transfer(from, to, tTransferAmount);
    }

    function _getCurrentReflectionRate() private view returns (uint256) {
        (uint256 rSupplyCurrent, uint256 tSupplyCurrent) = _getCurrentSupplies();
        return rSupplyCurrent.div(tSupplyCurrent);
    }

    function _getCurrentSupplies() private view returns (uint256, uint256) {
        uint256 rSupplyCurrent = _rTotal;
        uint256 tSupplyCurrent = _tTotal;
        for(uint256 i = 0; i < _excludedFromReflections.length; i++) {
            if(_rOwned[_excludedFromReflections[i]] > rSupplyCurrent || _tOwned[_excludedFromReflections[i]] > tSupplyCurrent) {
                return (_rTotal, _tTotal);
            }
            rSupplyCurrent = rSupplyCurrent.sub(_rOwned[_excludedFromReflections[i]]);
            tSupplyCurrent = tSupplyCurrent.sub(_tOwned[_excludedFromReflections[i]]);
        }
        if(rSupplyCurrent < _rTotal.div(_tTotal)) {
            return (_rTotal, _tTotal);
        }
        return (rSupplyCurrent, tSupplyCurrent);
    }

    function _liquidateFees(uint256 liquifyFactor) private internalSwapLock() {
        require(liquifyFactor <= 100, "liquify factor cannot exceed 100");

        uint256 tManagementFeesAmountToLiquidate = _amountManagementFeesPendingLiquidation.mul(liquifyFactor).div(100);
        uint256 tReserveFeesAmountToLiquidate = _amountReserveFeesPendingLiquidation.mul(liquifyFactor).div(100);
        
        uint256 tTotalFeesAmountToLiquidate = tManagementFeesAmountToLiquidate + tReserveFeesAmountToLiquidate;

        uint256 preSwapContractBalance = _contextAddress().balance;

        address[] memory path = new address[](2);
        path[0] = _contextAddress();
        path[1] = _pancakeRouter.WETH();

        _approve(_contextAddress(), address(_pancakeRouter), tTotalFeesAmountToLiquidate);
        _pancakeRouter.swapExactTokensForETHSupportingFeeOnTransferTokens(tTotalFeesAmountToLiquidate, 0, path, _contextAddress(), _msgTimestamp());

        emit SwapTokensForETH(tTotalFeesAmountToLiquidate, path);
        
        _amountManagementFeesPendingLiquidation = _amountManagementFeesPendingLiquidation.sub(tManagementFeesAmountToLiquidate);
        _amountReserveFeesPendingLiquidation = _amountReserveFeesPendingLiquidation.sub(tReserveFeesAmountToLiquidate);
        _amountTotalFeesPendingLiquidation = _amountManagementFeesPendingLiquidation + _amountReserveFeesPendingLiquidation;

        uint256 individualManagementFeesRecieverDistribution = _contextAddress().balance.sub(preSwapContractBalance).mul(tManagementFeesAmountToLiquidate).div(tTotalFeesAmountToLiquidate).div(_managementFeesRecievers.length);
        for(uint256 i = 0; i < _managementFeesRecievers.length; i++){
            payable(_managementFeesRecievers[i]).transfer(individualManagementFeesRecieverDistribution);
        }
    }

    function _buybackTokens(uint256 buybackFactor) private internalSwapLock() {
        require(buybackFactor <= 100, "buyback factor cannot exceed 100");

        address[] memory path = new address[](2);
        path[0] = _pancakeRouter.WETH();
        path[1] = _contextAddress();

        uint256 reserveETHToUse = _contextAddress().balance.mul(buybackFactor).div(100);

        _pancakeRouter.swapExactETHForTokensSupportingFeeOnTransferTokens{value: reserveETHToUse}(0, path, _deadAddress, _msgTimestamp().add(300));

        emit SwapETHForTokens(reserveETHToUse, path);
    }

    function _reinjectTokens(uint256 reinjectFactor) private internalSwapLock() {
        require(reinjectFactor <= 100, "reinject factor cannot exceed 100");

        uint256 deadTokensAvalible = balanceOf(_deadAddress);
        _transfer(_deadAddress, _contextAddress(), deadTokensAvalible);
        _approve(_contextAddress(), address(_pancakeRouter), deadTokensAvalible);

        _pancakeRouter.addLiquidityETH{value: _contextAddress().balance.mul(reinjectFactor).div(100)}(_contextAddress(), deadTokensAvalible, 0, 0, _contextAddress(), _msgTimestamp());

        _transfer(_contextAddress(), _deadAddress, balanceOf(_contextAddress()).sub(_amountTotalFeesPendingLiquidation));
    }


    function excludeFromReflections(address account) public onlyManagement() returns (bool) {
        require(!_isExcludedFromReflections[account], "account is already excluded from reflections");
        require(account != _deadAddress, "cannot include dead address in reflections");
        if(_rOwned[account] > 0) {
            _tOwned[account] = _rOwned[account].div(_getCurrentReflectionRate());
        }
        _isExcludedFromReflections[account] = true;
        _excludedFromReflections.push(account);
        return true;
    }

    function includeInReflections(address account) public onlyManagement() returns (bool) {
        require(account != _contextAddress(), "cannot include token address in reflections");
        require(account != address(_pancakePair), "cannot include pancake pair in reflections");
        require(_isExcludedFromReflections[account], "account is already included in reflections");
        for(uint256 i = 0; i < _excludedFromReflections.length; i++) {
            if(_excludedFromReflections[i] == account){
                _excludedFromReflections[i] = _excludedFromReflections[_excludedFromReflections.length - 1];
                _tOwned[account] = 0;
                _isExcludedFromReflections[account] = false;
                _excludedFromReflections.pop();
                break;
            }
        }
        return true;
    }

    function excludeFromFees(address account) public onlyManagement() returns (bool) {
        _isExcludedFromFees[account] = true;
        return true;
    }

    function includeInFees(address account) public onlyManagement() returns (bool) {
        require(account != _contextAddress(), "cannot include token address in fees");
        require(account != _deadAddress, "cannot include dead address in fees");
        _isExcludedFromFees[account] = false;
        return true;
    }

    function excludeFromLimits(address account) public onlyManagement() returns (bool) {
        _isExcludedFromLimits[account] = true;
        return true;
    }

    function includeInLimits(address account) public onlyManagement() returns (bool) {
        require(account != _contextAddress(), "cannot include token address in limits");
        require(account != _deadAddress, "cannot include dead address in limits");
        _isExcludedFromLimits[account] = false;
        return true;
    }


    function addManagementFeesReciever(address managementFeesReciever) public onlyManagement() returns (bool) {
        require(!_isManagementFeesReciever[managementFeesReciever], "address is already a management fees reciever");
        require(_managementFeesRecievers.length < _maxNumberManagementFeesRecievers, "max number of management fees recievers already reached");
        _managementFeesRecievers.push(managementFeesReciever);
        _isManagementFeesReciever[managementFeesReciever] = true;
        return true;
    }

    function removeManagementFeesReciever(address managementFeesReciever) public onlyManagement() returns (bool) {
        require(_isManagementFeesReciever[managementFeesReciever], "address is already not a management fees reciever");
        for(uint256 i = 0; i < _managementFeesRecievers.length; i++) {
            if(_managementFeesRecievers[i] == managementFeesReciever){
                _managementFeesRecievers[i] = _managementFeesRecievers[_excludedFromReflections.length - 1];
                _isManagementFeesReciever[managementFeesReciever] = false;
                _managementFeesRecievers.pop();
                break;
            }
        }
        return true;
    }

    function setFeesEnabled(bool areFeesEnabled) public onlyManagement() returns (bool) {
        _areFeesEnabled = areFeesEnabled;
        if(!areFeesEnabled){
            _isAutoFeeLiquifyEnabled = false;
        }
        return true;
    }

    function setFeesEnabled(bool areFeesEnabled, bool isAutoFeeLiquifyEnabled) public onlyManagement() returns (bool) {
        _areFeesEnabled = areFeesEnabled;
        if(!areFeesEnabled){
            _isAutoFeeLiquifyEnabled = false;
        } else {
            _isAutoFeeLiquifyEnabled = isAutoFeeLiquifyEnabled;
        }
        return true;
    }

    function setManagementFeeBuy(uint256 managementFeeBuy) public onlyManagement() returns (bool) {
        require(_buyFeeTotalPercentage - _buyFeeManagementPercentage + managementFeeBuy <= 20, "total buy fees cannot exceed 20");
        _buyFeeManagementPercentage = managementFeeBuy;
        _buyFeeTotalPercentage = _buyFeeManagementPercentage + _buyFeeReservePercentage + _buyFeeReflectionPercentage;
        return true;
    }

    function setManagementFeeSell(uint256 managementFeeSell) public onlyManagement() returns (bool) {
        require(_sellFeeTotalPercentage - _sellFeeManagementPercentage + managementFeeSell <= 20, "total sell fees cannot exceed 20");
        _sellFeeManagementPercentage = managementFeeSell;
        _sellFeeTotalPercentage = _sellFeeManagementPercentage + _sellFeeReservePercentage + _sellFeeReflectionPercentage;
        return true;
    }

    function setReserveFeeBuy(uint256 reserveFeeBuy) public onlyManagement() returns (bool) {
        require(_buyFeeTotalPercentage - _buyFeeReservePercentage + reserveFeeBuy <= 20, "total buy fees cannot exceed 20");
        _buyFeeReservePercentage = reserveFeeBuy;
        _buyFeeTotalPercentage = _buyFeeManagementPercentage + _buyFeeReservePercentage + _buyFeeReflectionPercentage;
        return true;
    }

    function setReserveFeeSell(uint256 reserveFeeSell) public onlyManagement() returns (bool) {
        require(_sellFeeTotalPercentage - _sellFeeReservePercentage + reserveFeeSell <= 20, "total sell fees cannot exceed 20");
        _sellFeeReservePercentage = reserveFeeSell;
        _sellFeeTotalPercentage = _sellFeeManagementPercentage + _sellFeeReservePercentage + _sellFeeReflectionPercentage;
        return true;
    }

    function setReflectionsFeeBuy(uint256 reflectionsFeeBuy) public onlyManagement() returns (bool) {
        require(_buyFeeTotalPercentage - _buyFeeReflectionPercentage + reflectionsFeeBuy <= 20, "total buy fees cannot exceed 20");
        _buyFeeReflectionPercentage = reflectionsFeeBuy;
        _buyFeeTotalPercentage = _buyFeeManagementPercentage + _buyFeeReservePercentage + _buyFeeReflectionPercentage;
        return true;
    }

    function setReflectionsFeeSell(uint256 reflectionsFeeSell) public onlyManagement() returns (bool) {
        require(_sellFeeTotalPercentage - _sellFeeReflectionPercentage + reflectionsFeeSell <= 20, "total sell fees cannot exceed 20");
        _sellFeeReflectionPercentage = reflectionsFeeSell;
        _sellFeeTotalPercentage = _sellFeeManagementPercentage + _sellFeeReservePercentage + _sellFeeReflectionPercentage;
        return true;
    }

    function setAutoFeeLiquifyEnabled(bool isAutoFeeLiquifyEnabled) public onlyManagement() returns (bool) {
        require(_areFeesEnabled || !isAutoFeeLiquifyEnabled, "fees must be enabled to enable auto fee liquify");
        _isAutoFeeLiquifyEnabled = isAutoFeeLiquifyEnabled;
        return true;
    }

    function setAutoLiquifyFactor(uint256 autoLiquifyFactor) public onlyManagement() returns (bool) {
        require(autoLiquifyFactor <= 100, "auto liquify factor cannot eceed 100");
        _autoLiquifyFactor = autoLiquifyFactor;
        return true;
    }

    function setMinPendingFeesForAutoLiquify(uint256 minPendingFeesForAutoLiquify) public onlyManagement() returns (bool) {
        _minPendingFeesForAutoLiquify = minPendingFeesForAutoLiquify;
        return true;
    }

    function setAutoBuybackEnabled(bool isAutoBuybackEnabled) public onlyManagement() returns (bool) {
        _isAutoBuybackEnabled = isAutoBuybackEnabled;
        return true;
    }

    function setMinReserveETHForAutoBuyback(uint256 minReserveETHForAutoBuyback) public onlyManagement() returns (bool) {
        _minReserveETHForAutoBuyback = minReserveETHForAutoBuyback;
        return true;
    }

    function setAutoBuybackFactor(uint256 autoBuybackFactor) public onlyManagement() returns (bool) {
        require(autoBuybackFactor <= 100, "auto buyback factor cannot exceed 100");
        _autoBuybackFactor = autoBuybackFactor;
        return true;
    }

    function setAutoReinjectEnabled(bool isAutoReinjectEnabled) public onlyManagement() returns (bool) {
        _isAutoReinjectEnabled = isAutoReinjectEnabled;
        return true;
    }

    function setMinReserveETHForAutoReinject(uint256 minReserveETHForAutoReinject) public onlyManagement() returns (bool) {
        _minReserveETHForAutoReinject = minReserveETHForAutoReinject;
        return true;
    }

    function setAutoReinjectFactor(uint256 autoReinjectFactor) public onlyManagement() returns (bool){
        require(autoReinjectFactor <= 100, "auto reinject factor cannot exceed 100");
        _autoReinjectFactor = autoReinjectFactor;
        return true;
    }

    function setLimitsEnabled(bool areLimitsEnabled) public onlyManagement() returns (bool) {
        _areLimitsEnabled = areLimitsEnabled;
        return true;
    }

    function setMaxTransferAmount(uint256 maxTransferAmount) public onlyManagement() returns (bool) {
        require(maxTransferAmount <= _tTotal, "max transfer amount cannot exceed token supply");
        _maxTransferAmount = maxTransferAmount;
        return true;
    }

    function performManualTokenBuyback(uint256 buybackFactor) public onlyManagement() returns (bool) {
        _buybackTokens(buybackFactor);
        return true;
    }

    function performManualFeeLiquidation(uint256 liquifyFactor) public onlyManagement() returns (bool) {
        _liquidateFees(liquifyFactor);
        return true;
    }

    function performManualDeadTokenReinjecton(uint256 reinjectFactor) public onlyManagement() returns (bool) {
        _reinjectTokens(reinjectFactor);
        return true;
    }

    

    modifier internalSwapLock() {
        _isInternallySwapping = true;
        _;
        _isInternallySwapping = false;
    }



    event SwapTokensForETH(uint256 amountTokens, address[] path);

    event SwapETHForTokens(uint256 amountETH, address[] path);

    event MintTokens(uint256 amountTokens);

    event ReflectTokens(uint256 amountTokens);

}