// SPDX-License-Identifier: MIT
pragma solidity ^0.8.7;


contract Callable {

    address payable private _context;
    address private _creator;

    constructor() { 
        _context = payable(address(this));
        _creator = msg.sender;
        emit CreateContext(_context, _creator);
    }


    function _contextAddress() internal view returns (address payable) {
        return _context;
    }

    function _contextCreator() internal view returns (address) {
        return _creator;
    }

    function _msgSender() internal view returns (address payable) {
        return payable(msg.sender);
    }

    function _msgData() internal view returns (bytes memory) {
        this;
        return msg.data;
    }

    function _msgTimestamp() internal view returns (uint256) {
        this;
        return block.timestamp;
    }


    receive() external payable { }


    event CreateContext(address contextAddress, address contextCreator);
    
}