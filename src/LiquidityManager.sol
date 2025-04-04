// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "./Minter.sol"; // Import the Minter contract

interface IDexPool {
    function mint(address to, uint256 amount) external returns (uint256 liquidity);
    // function deposit(address tokenA, address tokenB, uint256 amountA, uint256 amountB) external returns (uint256 liquidity);
    function withdraw(address tokenA, address tokenB, uint256 liquidityAmount, address recipient) external returns (uint256 amountA, uint256 amountB);
    function getReserves() external view returns (uint256 reserveA, uint256 reserveB);
    function totalSupply() external view returns (uint256);
    function balanceOf(address account) external view returns (uint256);
    function token0() external view returns (address);
    function token1() external view returns (address);  
}

contract LiquidityManager is Ownable {
    Minter public minter;
    mapping(address => mapping(address => uint256)) public userLpBalances; // user => pool => lpAmount

    event LiquidityMinted(address indexed user, address indexed pool, uint256 amount, uint256 liquidity);
    event LiquidityBurned(address indexed user, address indexed pool, uint256 amountA, uint256 amountB, uint256 liquidityBurned);

    constructor() Ownable(msg.sender) {
        // require(_minter != address(0), "LiquidityManager: Minter address cannot be zero");
        // minter = Minter(_minter);
    }

    modifier onlyListener() {
        require(msg.sender == minter.listener(), "LiquidityManager: Caller is not the Listener");
        _;
    }

    function setMinter(address _minter) public onlyOwner {
        require(_minter != address(0), "LiquidityManager: Minter address cannot be zero");
        minter = Minter(_minter);
    }

    function mintNewLPPosition(
        address user,
        address poolAddress,
        uint256 amount,
        address tokenA,
        address tokenB
    ) public onlyListener {
        require(amount > 0 , "LiquidityManager: Mint amounts must be greater than zero");
        require(tokenA != address(0) && tokenB != address(0), "LiquidityManager: Token addresses cannot be zero");
        require(poolAddress != address(0), "LiquidityManager: Pool address cannot be zero");

        address prTokenA = minter.getPrToken(tokenA);
        address prTokenB = minter.getPrToken(tokenB);
        require(prTokenA != address(0) && prTokenB != address(0), "LiquidityManager: prERC20 tokens not mapped");

        // Mint prERC20 tokens
        minter.mint(tokenA, address(this), amount /2);
        minter.mint(tokenB, address(this), amount/2);

        // Approve the pool to spend the minted prERC20 tokens
        IERC20(prTokenA).approve(poolAddress, amount /2);
        IERC20(prTokenB).approve(poolAddress, amount /2);

        // Deposit into the pool
        uint256 liquidity = IDexPool(poolAddress).mint(
            user,
            amount
        );

        userLpBalances[user][poolAddress] += liquidity;

        emit LiquidityMinted(user, poolAddress, amount, liquidity);



        // TODO: Emit an event to notify the LiquidityHub about the successful minting
        // and the user's new LP position on this rollup.
    }

    function burnLPPosition(
        address user,
        address poolAddress,
        uint256 liquidityAmount,
        address tokenA,
        address tokenB
    ) public onlyListener {
        require(liquidityAmount > 0, "LiquidityManager: Burn amount must be greater than zero");
        require(tokenA != address(0) && tokenB != address(0), "LiquidityManager: Token addresses cannot be zero");
        require(poolAddress != address(0), "LiquidityManager: Pool address cannot be zero");
        require(userLpBalances[user][poolAddress] >= liquidityAmount, "LiquidityManager: Insufficient LP tokens for user in this pool");

        address prTokenA = minter.getPrToken(tokenA);
        address prTokenB = minter.getPrToken(tokenB);
        require(prTokenA != address(0) && prTokenB != address(0), "LiquidityManager: prERC20 tokens not mapped");

        // Approve the pool to spend the user's LP tokens (assuming the pool manages LP tokens)
        IERC20(IDexPool(poolAddress).token0()).approve(poolAddress, type(uint256).max); // Approve max for simplicity, consider a more precise approach
        IERC20(IDexPool(poolAddress).token1()).approve(poolAddress, type(uint256).max); // Approve max for simplicity

        // Withdraw liquidity from the pool
        (uint256 amountA, uint256 amountB) = IDexPool(poolAddress).withdraw(
            prTokenA,
            prTokenB,
            liquidityAmount,
            address(this)
        );

        userLpBalances[user][poolAddress] -= liquidityAmount;

        // Burn the prERC20 tokens
        minter.burn(prTokenA, address(this), amountA);
        minter.burn(prTokenB, address(this), amountB);

        emit LiquidityBurned(user, poolAddress, amountA, amountB, liquidityAmount);
        // TODO: Emit an event to notify the LiquidityHub about the successful burning
        // and the decrease in the user's global LP position.
    }
}