# The Coin Sack Token
This repository contains source code used to deploy the Coin Sack Token - a BEP-20 token featuring: 100 billion token total supply; 3 decimal point fungibility; 15% PancakeSwap buy fees; 20% PancakeSwap sell fees; No fees applied to other transfers; Strategic reserve with automatic token buyback and recycling capabilities.
___

## Official Deployments
#### CS on the Binance Smart Chain Mainnet: [`0x125Ce3f13950C5fA94397927F88C352FdED680Ad`](https://bscscan.com/token/0x125Ce3f13950C5fA94397927F88C352FdED680Ad)
#### CS on the Binance Smart Chain Testnet: [`0x8307d42ecf950935c47Afcb9fC4c1f74cF3F938C`](https://testnet.bscscan.com/token/0x8307d42ecf950935c47Afcb9fC4c1f74cF3F938C)
_\*Contact the Coin Sack team via [Tetegram](https://t.me/coinsack) to for instructions to obtain Testnet CS and participate in test deployments._
___

## `contract CoinSackToken is IBEP20, Manageable`

###### `constructor(address pancakeRouter)`
###### `function increaseAllowance(address spender, uint256 amount) public returns (bool)`
###### `function decreaseAllowance(address spender, uint256 amount) public returns (bool)`
###### `function isExcludedFromReflections(address account)`
###### `function isExcludedFromFees(address account) public view returns (bool)`
###### `function isExcludedFromLimits(address account) public view returns (bool)`
###### `function excludeFromReflections(address account) public onlyManagement() returns (bool)`
###### `function includeInReflections(address account) public onlyManagement() returns (bool)`
###### `function excludeFromFees(address account) public onlyManagement() returns (bool)`
###### `function includeInFees(address account) public onlyManagement() returns (bool)`
###### `function excludeFromLimits(address account) public onlyManagement() returns (bool)`
###### `function includeInLimits(address account) public onlyManagement() returns (bool)`
###### `function addManagementFeesReciever(address managementFeesReciever) public onlyManagement() returns (bool)`
###### `function removeManagementFeesReciever(address managementFeesReciever) public onlyManagement() returns (bool)`
###### `function setFeesEnabled(bool areFeesEnabled) public onlyManagement() returns (bool)`
###### `function setFeesEnabled(bool areFeesEnabled, bool isAutoFeeLiquifyEnabled) public onlyManagement() returns (bool)`
###### `function setManagementFeeBuy(uint256 managementFeeBuy) public onlyManagement() returns (bool)`
###### `function setManagementFeeSell(uint256 managementFeeSell) public onlyManagement() returns (bool)`
###### `function setReserveFeeBuy(uint256 reserveFeeBuy) public onlyManagement() returns (bool)`
###### `function setReserveFeeSell(uint256 reserveFeeSell) public onlyManagement() returns (bool)`
###### `function setReflectionsFeeBuy(uint256 reflectionsFeeBuy) public onlyManagement() returns (bool)`
###### `function setReflectionsFeeSell(uint256 reflectionsFeeSell) public onlyManagement() returns (bool)`
###### `function setAutoFeeLiquifyEnabled(bool isAutoFeeLiquifyEnabled) public onlyManagement() returns (bool)`
###### `function setAutoLiquifyFactor(uint256 autoLiquifyFactor) public onlyManagement() returns (bool)`
###### `function setMinPendingFeesForAutoLiquify(uint256 minPendingFeesForAutoLiquify) public onlyManagement() returns (bool)`
###### `function setAutoBuybackEnabled(bool isAutoBuybackEnabled) public onlyManagement() returns (bool)`
###### `function setMinReserveETHForAutoBuyback(uint256 minReserveETHForAutoBuyback) public onlyManagement() returns (bool)`
###### `function setAutoBuybackFactor(uint256 autoBuybackFactor) public onlyManagement() returns (bool)`
###### `function setAutoReinjectEnabled(bool isAutoReinjectEnabled) public onlyManagement() returns (bool)`
###### `function setMinReserveETHForAutoReinject(uint256 minReserveETHForAutoReinject) public onlyManagement() returns (bool)`
###### `function setAutoReinjectFactor(uint256 autoReinjectFactor) public onlyManagement() returns (bool)`
###### `function setLimitsEnabled(bool areLimitsEnabled) public onlyManagement() returns (bool)`
###### `function setMaxTransferAmount(uint256 maxTransferAmount) public onlyManagement() returns (bool)`
###### `function performManualTokenBuyback(uint256 buybackFactor) public onlyManagement() returns (bool)`
###### `function performManualFeeLiquidation(uint256 liquifyFactor) public onlyManagement() returns (bool)`
###### `function performManualDeadTokenReinjecton(uint256 reinjectFactor) public onlyManagement() returns (bool)`
###### `event SwapTokensForETH(uint256 amountTokens, address[] path)`
###### `event SwapETHForTokens(uint256 amountETH, address[] path)`
###### `event MintTokens(uint256 amountTokens)`
###### `event ReflectTokens(uint256 amountTokens)`
###### `modifier internalSwapLock()`

## ` `
###### `function name() external view returns (string memory)`
###### `function symbol() external view returns (string memory)`
###### `function decimals() external view returns (uint8)`
###### `function totalSupply() external view returns (uint)`
###### `function balanceOf(address owner) external view returns (uint)`
###### `function allowance(address owner, address spender) external view returns (uint)`
###### `function approve(address spender, uint value) external returns (bool)`
###### `function transfer(address to, uint value) external returns (bool)`
###### `function transferFrom(address from, address to, uint value) external returns (bool)`
###### `event Approval(address indexed owner, address indexed spender, uint value)`
###### `event Transfer(address indexed from, address indexed to, uint value)`

## `contract Callable`
###### `function _contextAddress() internal view returns (address payable)`
###### `function _contextCreator() internal view returns (address)`
###### `function _msgSender() internal view returns (address payable)`
###### `function _msgData() internal view returns (bytes memory)`
###### `function _msgTimestamp() internal view returns (uint256)`
###### `receive() external payable`
###### `event CreateContext(address contextAddress, address contextCreator)`

## `contract Manageable is Callable`
###### `function executiveManager() public view returns (address)`
###### `function isManager(address account) public view returns (bool)`
###### `function managementIsLocked() public view returns (bool)`
###### `function timeToManagementUnlock() public view returns (uint256)`
###### `function addManager(address newManager) public onlyExecutive() returns (bool)`
###### `function removeManager(address managerToRemove) public onlyExecutive() returns (bool)`
###### `function changeExecutiveManager(address newExecutiveManager) public onlyExecutive() returns (bool)`
###### `function lockManagement(uint256 lockDuration) public onlyExecutive() returns (bool)`
###### `function unlockManagement() public onlyExecutive() returns (bool)`
###### `function renounceManagement() public onlyExecutive() returns (bool)`
###### `event ManagerAdded(address addedManager)`
###### `event ManagerRemoved(address removedManager)`
###### `event ExecutiveManagerChanged(address indexed previousExecutiveManager, address indexed newExecutiveManager)`
###### `event ManagementLocked(uint256 lockDuration)`
###### `event ManagementUnlocked()`
###### `event ManagementRenounced()`
###### `modifier onlyExecutive()`
###### `modifier onlyManagement()`
___

## Project Source

Source code files for The Coin Sack token's smart contract can be found in the `contracts` subdirectory. Contracts are built / deployed using the Truffle suite; compiled using solc version 0.8.7. 

This project's Truffle suite configuration can be found in the `truffle-config.js` file; the Node package configuration is set within the `package.json` file. Package scripts to call common truffle commands are setup:
```
$ npm run compile       # Compile Smart Contracts
$ npm run migrate       # Deploy Smart Contracts
$ npm run verify        # Verify Deployment on BSCScan
```
___

## The Coin Sack Project
Coin Sack was created with the belief that there need to be stronger, more trustworthy, and more worthwhile projects built throughout the deFi space. We decided to take this into our own hands by launching Coin Sack; a BEP-20 token featuring battle tested tokenomics, an innovative future roadmap, and a trustworthy team that cares for its investors.

Check out the Coin Sack project online at [Coin-Sack.com](https://coin-sack.com/)!