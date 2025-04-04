// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/utils/math/Math.sol";
import "./LPToken.sol";

interface IPool {
    // function swap(
    //     uint256 amount0Out,
    //     uint256 amount1Out,
    //     address to,
    //     bytes calldata data
    // ) external;

    function token0() external view returns (address);

    function token1() external view returns (address);

    function getReserves() external view returns (uint112 reserve0, uint112 reserve1, uint32 blockTimestampLast);

    function mint(address to, uint256 amount) external returns (uint liquidity);

    function burn(address to, uint256 amount) external returns (uint amount0);

    function totalSupply() external view returns (uint);

    function balanceOf(address account) external view returns (uint);
}

contract DexPool is Ownable(msg.sender), IPool {
    using Math for uint256;

    address public override token0;
    address public override token1;

    uint256 public  reserve0;
    uint256 public  reserve1;

    uint32 public  blockTimestampLast;

    uint256 public override totalSupply;
    mapping(address => uint256) public override balanceOf;

    LPToken public lpToken;

    constructor(address _token0, address _token1, address _lpToken) {
        token0 = _token0;
        token1 = _token1;
        lpToken = LPToken(_lpToken);
    }

    function setLPToken(address _lptoken) public {
        lpToken = LPToken(_lptoken);
    }

    function _update(uint256 _reserve0, uint256 _reserve1) internal {
        reserve0 = _reserve0;
        reserve1 = _reserve1;
        blockTimestampLast = uint32(block.timestamp % 2**32);
    }

    function mint(address to, uint256 amount) external override returns (uint256 liquidity) {
        
        // Transfer equal amounts of token0 and token1
        IERC20(token0).transferFrom(msg.sender, address(this), amount / 2); // fix - transferfrom
        IERC20(token1).transferFrom(msg.sender, address(this), amount / 2);

        uint256 token0Balance = IERC20(token0).balanceOf(address(this));
        uint256 token1Balance = IERC20(token1).balanceOf(address(this));

        liquidity = amount;

        totalSupply += liquidity;
        balanceOf[to] += liquidity;

        _update(token0Balance, token1Balance); // Update reserves

        lpToken.mintTo(msg.sender, liquidity);

        return liquidity;
    }

    // function swap(
    //     uint256 amount0Out,
    //     uint256 amount1Out,
    //     address to,
    //     bytes calldata data
    // ) external override onlyOwner {
    //     // Simplified swap logic (constant product formula)
    //     require(amount0Out > 0 || amount1Out > 0, "INSUFFICIENT_OUTPUT_AMOUNT");

    //     uint256 reserve0In = reserve0;
    //     uint256 reserve1In = reserve1;
    //     uint256 reserve0Out_ = amount0Out;   
    //     uint256 reserve1Out_ = amount1Out;

    //     uint256 amount0In = 0;
    //     uint256 amount1In = 0;

    //     if (amount0Out > 0) {
    //         amount0In = amount0Out * reserve1In / (reserve1In - amount1Out) + 1;
    //     } else {
    //         amount1In = amount1Out * reserve0In / (reserve0In - amount0Out) + 1;
    //     }

    //     require(reserve0In >= amount0Out && reserve1In >= amount1Out, "INSUFFICIENT_LIQUIDITY");

    //     _update(reserve0In + amount0In - reserve0Out_, reserve1In + amount1In - amount1Out_);
    //     IERC20(token0).transfer(to, amount0Out);
    //     IERC20(token1).transfer(to, amount1Out);
    // }

    function getReserves() external override view returns (uint112 _reserve0, uint112 _reserve1, uint32 _blockTimestampLast) {
        return (uint112(reserve0), uint112(reserve1), blockTimestampLast);
    }

    function burn(address to, uint256 amount) external override returns (uint res) {
        uint256 balance0 = IERC20(token0).balanceOf(address(this));
        uint256 balance1 = IERC20(token1).balanceOf(address(this));
        // uint256 liquidity = balanceOf[to];

        // uint256 totalSupply_ = totalSupply;

        // amount0 = liquidity * balance0 / totalSupply_;
        // amount1 = liquidity * balance1 / totalSupply_;

        totalSupply -= amount;
        // balanceOf[to] = 0;

        // _update(balance0 - amount0, balance1 - amount1);

        res = amount / 2;

        IERC20(token0).transfer(to, res);
        IERC20(token1).transfer(to, res);
        lpToken.burnFrom(to, amount); 

        // return (amount0, amount1);
    }

    function _mint(address to, uint256 value) internal {
        balanceOf[to] += value;
        totalSupply += value;
    }

    function _burn(address from, uint256 value) internal {
        require(balanceOf[from] >= value, "ERC20: burn amount exceeds balance");
        unchecked {
            balanceOf[from] -= value;
        }
        totalSupply -= value;
    }
}