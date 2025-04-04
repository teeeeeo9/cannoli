// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "./prERC20.sol"; // Import the PrERC20 contract


contract Minter is Ownable {
    address public liquidityManager;
    address public listener;
    address public dexInterface;

    // Mapping of original token address to its prERC20 token address
    mapping(address => address) public originalToPrToken;
    mapping(address => address) public prTokenToOriginal;

    constructor(address _liquidityManager, address _listener) Ownable(msg.sender) {
        require(_liquidityManager != address(0) && _listener != address(0), "Minter: Addresses cannot be zero");
        liquidityManager = _liquidityManager;
        listener = _listener;
    }

    modifier onlyLiquidityManagerOrListener() {
        require(msg.sender == liquidityManager || msg.sender == listener || msg.sender == dexInterface, "Minter: Caller is not Liquidity Manager or Listener");
        _;
    }

    function setLiquidityManager(address _liquidityManager) public onlyOwner {
        require(_liquidityManager != address(0), "Minter: Address cannot be zero");
        liquidityManager = _liquidityManager;
    }

    function setListener(address _listener) public onlyOwner {
        require(_listener != address(0), "Minter: Address cannot be zero");
        listener = _listener;
    }

    function setDexInterface(address _dexInterface) public onlyOwner {
        require(_dexInterface != address(0), "Minter: Address cannot be zero");
        dexInterface = _dexInterface;
    }    

    function mapTokens(address originalToken, address prToken) public onlyOwner {
        require(originalToken != address(0) && prToken != address(0), "Minter: Addresses cannot be zero");
        require(originalToPrToken[originalToken] == address(0) && prTokenToOriginal[prToken] == address(0), "Minter: Token mapping already exists");
        originalToPrToken[originalToken] = prToken;
        prTokenToOriginal[prToken] = originalToken;
    }

    function unmapTokens(address originalToken, address prToken) public onlyOwner {
        require(originalToken != address(0) && prToken != address(0), "Minter: Addresses cannot be zero");
        require(originalToPrToken[originalToken] == prToken && prTokenToOriginal[prToken] == originalToken, "Minter: Token mapping does not exist");
        delete originalToPrToken[originalToken];
        delete prTokenToOriginal[prToken];
    }

    function mint(address originalToken, address to, uint256 amount) public onlyLiquidityManagerOrListener {
        address prTokenAddress = originalToPrToken[originalToken];
        require(prTokenAddress != address(0), "Minter: No prERC20 token mapped for the original token");
        prERC20(prTokenAddress).mint(to, amount);
    }

    function burn(address prToken, address from, uint256 amount) public onlyLiquidityManagerOrListener {
        address originalTokenAddress = prTokenToOriginal[prToken];
        require(originalTokenAddress != address(0), "Minter: Not a registered prERC20 token");
        prERC20(prToken).burn(from, amount);
    }

    // View function to get the prERC20 address for an original token
    function getPrToken(address originalToken) public view returns (address) {
        return originalToPrToken[originalToken];
    }

    // View function to get the original token address for a prERC20 token
    function getOriginalToken(address prToken) public view returns (address) {
        return prTokenToOriginal[prToken];
    }
}