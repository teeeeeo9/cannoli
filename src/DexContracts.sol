// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";



interface IUniswapV2Factory {
    function createPair(address tokenA, address tokenB) external returns (address pair);
}

interface IUniswapV2Pair {
    function mint(address to) external returns (uint liquidity);

    function swap(
        uint amount0Out,
        uint amount1Out,
        address to,
        bytes calldata data
    ) external;
}

contract MockUniswapV2Factory is Ownable, IUniswapV2Factory {
    address public override createPair(address tokenA, address tokenB) external override returns (address pair) {
        pair = address(new MockUniswapV2Pair(tokenA, tokenB));
        return pair;
    }
}

contract MockUniswapV2Pair is Ownable, IUniswapV2Pair {
    address public token0;
    address public token1;

    uint256 public reserve0;
    uint256 public reserve1;

    constructor(address _token0, address _token1) Ownable() {
        token0 = _token0;
        token1 = _token1;
    }

    function _update(uint256 _reserve0, uint256 _reserve1) internal {
        reserve0 = _reserve0;
        reserve1 = _reserve1;
    }

    function mint(address to) external override onlyOwner returns (uint liquidity) {
        liquidity = 1000000; 
        _update(1000, 1000); 
        return liquidity;
    }

    function swap(
        uint amount0Out,
        uint amount1Out,
        address to,
        bytes calldata data
    ) external override onlyOwner {
        // Mock swap logic
        _update(reserve0 - amount0Out, reserve1 + amount1Out);
    }
}