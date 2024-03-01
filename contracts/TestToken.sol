// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "./ERC20FlashMint.sol";
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract TestToken is ERC20, ERC20FlashMint{

    address public owner;

    modifier onlyOwner(){
        require(msg.sender == owner, "Only owner");
        _;
    }

    constructor() ERC20("TestToken", "TES"){
        owner = msg.sender;
    }

    function mint(address to, uint amount) public onlyOwner{
        _mint(to, amount);
    }

    function _flashFee(address , uint amount) internal override pure returns(uint){
        return amount / 10000;
    }

    function _flashFeeReceiver() internal override view returns(address){
        return owner;
    } 
}