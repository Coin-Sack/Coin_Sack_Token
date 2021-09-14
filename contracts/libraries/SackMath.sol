// SPDX-License-Identifier: MIT
pragma solidity ^0.8.7;


library SackMath {

    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a, "addition overflow");
        return c;
    }


    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        if(b >= a){
            return 0;
        }
        uint256 c = a - b;
        return c;
    }

    function sub(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b <= a, errorMessage);
        uint256 c = a - b;
        return c;
    }


    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        if (a == 0 || b == 0) {
            return 0;
        }
        uint256 c = a * b;
        require(c / a == b, "multiplication overflow");
        return c;
    }



    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b > 0, "division by zero");
        uint256 c = a / b;
        return c;
    }


    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b != 0, "modulo by zero");
        return a % b;
    }

}