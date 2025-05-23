// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/token/ERC20/extensions/ERC20Burnable.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract MockERC20 is ERC20Burnable, Ownable(msg.sender) {
    constructor(string memory name, string memory symbol, uint8 decimals) ERC20(name, symbol) {
        _mint(msg.sender, 1000000000 * 10 ** decimals); 
    }

    function mint(address to, uint256 amount) public onlyOwner {
        _mint(to, amount);
    }
}