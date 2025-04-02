// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract MockERC20 is ERC20 {
    constructor(string memory _name, string memory _symbol, uint8 _decimals) ERC20(_name, _symbol, _decimals) {
        _mint(msg.sender, 1000000000 * 10 ** _decimals); 
    }

    function mint(address _to, uint256 _amount) public {
        _mint(_to, _amount);
    }
}

contract PromiseERC20 is MockERC20, Ownable {
    constructor(string memory _name, string memory _symbol, uint8 _decimals) MockERC20(_name, _symbol, _decimals) {}

    modifier onlyCannoliContracts() {
        require(msg.sender == address(this) || owner() == msg.sender, "PromiseERC20: Not Cannoli contract");
        _;
    }

    function mint(address _to, uint256 _amount) public override onlyCannoliContracts {
        _mint(_to, _amount);
    }

    function burn(address _from, uint256 _amount) public onlyCannoliContracts {
        _burn(_from, _amount);
    }
}

