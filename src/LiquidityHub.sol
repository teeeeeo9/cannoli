// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";

contract LiquidityHub is Ownable {
    using SafeMath for uint256;

    // Supported Tokens
    mapping(address => bool) public isSupportedToken;

    // Liquidity Provider (LP) Data
    struct LiquidityPosition {
        uint256 usdcAmount;
        uint256 usdtAmount;
        uint256 wethAmount;
        uint256 wbtcAmount;
        bool useRollup1;
        bool useRollup2;
    }
    mapping(address => LiquidityPosition) public liquidityPositions;

    // Rollup Addresses (Hardcoded for now)
    address public rollup1LiquidityManager;
    address public rollup2LiquidityManager;

    event LiquidityDeposited(
        address indexed lp,
        address token,
        uint256 amount,
        bool useRollup1,
        bool useRollup2
    );
    event LiquidityWithdrawn(
        address indexed lp,
        address token,
        uint256 amount
    );
    event LiquidityDecreased(
        address indexed lp,
        address token,
        uint256 amount
    );

    constructor(
        address _rollup1LiquidityManager,
        address _rollup2LiquidityManager
    ) Ownable() {
        rollup1LiquidityManager = _rollup1LiquidityManager;
        rollup2LiquidityManager = _rollup2LiquidityManager;
    }

    function addSupportedToken(address _token) public onlyOwner {
        isSupportedToken[_token] = true;
    }

    function depositLiquidity(
        address _token,
        uint256 _amount,
        bool _useRollup1,
        bool _useRollup2
    ) public {
        require(isSupportedToken[_token], "LiquidityHub: Unsupported token");
        require(_amount > 0, "LiquidityHub: Amount must be greater than 0");

        IERC20(_token).transferFrom(msg.sender, address(this), _amount);

        LiquidityPosition storage position = liquidityPositions[msg.sender];

        if (_token == USDC) {
            position.usdcAmount = position.usdcAmount.add(_amount);
        } else if (_token == USDT) {
            position.usdtAmount = position.usdtAmount.add(_amount);
        } else if (_token == WETH) {
            position.wethAmount = position.wethAmount.add(_amount);
        } else if (_token == WBTC) {
            position.wbtcAmount = position.wbtcAmount.add(_amount);
        } else {
            revert("LiquidityHub: Invalid token"); // Should never happen due to isSupportedToken check
        }

        liquidityPositions[msg.sender] = position;

        emit LiquidityDeposited(msg.sender, _token, _amount, _useRollup1, _useRollup2);
    }

    function withdrawLiquidity(address _token, uint256 _amount) public {
        require(_amount > 0, "LiquidityHub: Amount must be greater than 0");

        LiquidityPosition storage position = liquidityPositions[msg.sender];

        if (_token == USDC) {
            require(position.usdcAmount >= _amount, "LiquidityHub: Insufficient USDC liquidity");
            position.usdcAmount = position.usdcAmount.sub(_amount);
        } else if (_token == USDT) {
            require(position.usdtAmount >= _amount, "LiquidityHub: Insufficient USDT liquidity");
            position.usdtAmount = position.usdtAmount.sub(_amount);
        } else if (_token == WETH) {
            require(position.wethAmount >= _amount, "LiquidityHub: Insufficient WETH liquidity");
            position.wethAmount = position.wethAmount.sub(_amount);
        } else if (_token == WBTC) {
            require(position.wbtcAmount >= _amount, "LiquidityHub: Insufficient WBTC liquidity");
            position.wbtcAmount = position.wbtcAmount.sub(_amount);
        } else {
            revert("LiquidityHub: Invalid token"); // Should never happen due to isSupportedToken check
        }

        liquidityPositions[msg.sender] = position;

        IERC20(_token).transfer(msg.sender, _amount);

        emit LiquidityWithdrawn(msg.sender, _token, _amount);
    }

    function decreaseLiquidity(
        address _token,
        uint256 _amount,
        address _lp
    ) public {
        // Only Liquidity Managers should be able to call this
        require(msg.sender == rollup1LiquidityManager || msg.sender == rollup2LiquidityManager, "LiquidityHub: Unauthorized");
        require(_amount > 0, "LiquidityHub: Amount must be greater than 0");

        LiquidityPosition storage position = liquidityPositions[_lp];

        if (_token == USDC) {
            require(position.usdcAmount >= _amount, "LiquidityHub: Insufficient USDC liquidity");
            position.usdcAmount = position.usdcAmount.sub(_amount);
        } else if (_token == USDT) {
            require(position.usdtAmount >= _amount, "LiquidityHub: Insufficient USDT liquidity");
            position.usdtAmount = position.usdtAmount.sub(_amount);
        } else if (_token == WETH) {
            require(position.wethAmount >= _amount, "LiquidityHub: Insufficient WETH liquidity");
            position.wethAmount = position.wethAmount.sub(_amount);
        } else if (_token == WBTC) {
            require(position.wbtcAmount >= _amount, "LiquidityHub: Insufficient WBTC liquidity");
            position.wbtcAmount = position.wbtcAmount.sub(_amount);
        } else {
            revert("LiquidityHub: Invalid token"); // Should never happen due to isSupportedToken check
        }

        liquidityPositions[_lp] = position;

        emit LiquidityDecreased(_lp, _token, _amount);
    }

    // Functions to get liquidity info (for off-chain use)
    function getLiquidityPosition(address _lp)
        public
        view
        returns (
            uint256 usdc,
            uint256 usdt,
            uint256 weth,
            uint256 wbtc,
            bool useRollup1_,
            bool useRollup2_
        )
    {
        LiquidityPosition storage position = liquidityPositions[_lp];
        return (
            position.usdcAmount,
            position.usdtAmount,
            position.wethAmount,
            position.wbtcAmount,
            position.useRollup1,
            position.useRollup2
        );
    }

    // Token addresses
    address public USDC;
    address public USDT;
    address public WETH;
    address public WBTC;

    function setTokenAddresses(
        address _USDC,
        address _USDT,
        address _WETH,
        address _WBTC
    ) public onlyOwner {
        USDC = _USDC;
        USDT = _USDT;
        WETH = _WETH;
        WBTC = _WBTC;
    }
}