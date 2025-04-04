// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract prERC20 is ERC20, Ownable {
    address public minter;

    constructor(string memory name, string memory symbol) ERC20(name, symbol) Ownable(msg.sender) {
        // require(_minter != address(0), "Addresses cannot be zero");
        // minter = _minter;
    }

    // modifier onlyMinter() {
    //     require(msg.sender == minter, "Caller is not Minter ");
    //     _;
    // }

    function setMinter(address _minter) public onlyOwner {
        require(_minter != address(0), "Address cannot be zero");
        minter = _minter;
    }

    function mint(address to, uint256 amount) public {
        _mint(to, amount);
    }

    function burn(address from, uint256 amount) public {
        _burn(from, amount);
    }



}