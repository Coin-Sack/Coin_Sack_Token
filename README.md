# The Coin Sack Token
This repository contains source code used to deploy the Coin Sack Token - a BEP-20 token featuring: 100 billion token total supply; 3 decimal point fungibility; 15% PancakeSwap buy fees; 20% PancakeSwap sell fees; No fees applied to other transfers; Strategic reserve with automatic token buyback and recycling capabilities.
___

## Deployments
#### CS on the Binance Smart Chain Mainnet: [`0x125Ce3f13950C5fA94397927F88C352FdED680Ad`](https://bscscan.com/token/0x125Ce3f13950C5fA94397927F88C352FdED680Ad)
#### CS on the Binance Smart Chain Testnet: [`0x8307d42ecf950935c47Afcb9fC4c1f74cF3F938C`](https://testnet.bscscan.com/token/0x8307d42ecf950935c47Afcb9fC4c1f74cF3F938C)
_\*Contact the Coin Sack team via [Tetegram](https://t.me/coinsack) to for instructions to obtain Testnet CS and participate in test deployments._
___

## Contract Interface
#### `contract CoinSackToken is IBEP20, Manageable`
### BEP-20 Interface
#### ...
### Context Interface
The manageable context, inherited by the `CoinSackToken` contract allows an executive manager to add / remove contract managers. These accounts may call methods with the `onlyManagement()` modifier attached to them which are used to change token settings.
The ` onlyExecutive()` modifier tags functions which may only be called by the single,executive account.
#### `function executiveManager() public view returns (address)`
Get the address of the executive manager account. 
#### `function isManager(address account) public view returns (bool)`
Check if the provided account address is registered as a manager or not. 
#### `function managementIsLocked() public view returns (bool)`
Chect if management is locked or not. When management is locked, `onlyManagement()` methods cannot be called. 
#### `function timeToManagementUnlock() public view returns (uint256)`
Duration in seconds until management can be unlocked.
#### `function addManager(address newManager) public onlyExecutive() returns (bool)`
Make an account a contract manager. 
#### `function removeManager(address managerToRemove) public onlyExecutive() returns (bool)`
Remove an account's status as a contract manager. 
#### `function changeExecutiveManager(address newExecutiveManager) public onlyExecutive() returns (bool)`
Renounce executive management to another account.
#### `function lockManagement(uint256 lockDuration) public onlyExecutive() returns (bool)`
Lock contract management for the specified duration provided in seconds. 
#### `function unlockManagement() public onlyExecutive() returns (bool)`
Unlock contract management. Method call will fail if `timeToManagementUnlock()` is greater than zero.
#### `function renounceManagement() public onlyExecutive() returns (bool)`
Forever renounce all contract management. 
### Custom Interface
#### ...
___

## Contract Events
### BEP-20 Events
#### ...
### Context Events
#### ...
### Custom Events
#### ...
___

___

## Contract Source
...
___

## The Coin Sack Project
Coin Sack was created with the belief that there need to be stronger, more trustworthy, and more worthwhile projects built throughout the deFi space. We decided to take this into our own hands by launching Coin Sack; a BEP-20 token featuring battle tested tokenomics, an innovative future roadmap, and a trustworthy team that cares for its investors.

Check out the Coin Sack project online at [Coin-Sack.com](https://coin-sack.com/)!