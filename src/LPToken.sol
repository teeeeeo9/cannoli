// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/token/ERC20/extensions/ERC20Burnable.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract LPToken is ERC20Burnable  {
    constructor(string memory name, string memory symbol, uint8 decimals) 
    // constructor(string memory name, string memory symbol, uint8 decimals, address pool) 
        ERC20(name, symbol)
        // Ownable(pool)
    {
    }

    // Custom mint function for liquidity providers
    function mintTo(address to, uint256 amount) public  {
        _mint(to, amount);
    }

    function burnFrom(address account, uint256 amount) override public {
        _burn(account, amount);
    }  
}