// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "./Minter.sol"; 

interface IDexPool {
    function swap(
        address tokenIn,
        address tokenOut,
        uint256 amountIn,
        // uint256 amountOutMin,
        address to,
        bytes calldata data
    ) external returns (uint256 amountOut);

    function token0() external view returns (address);

    function token1() external view returns (address);
}

contract DexInterface is Ownable {
    Minter public minter;

    event SwapInitiated(
        address indexed user,
        address indexed pool,
        address tokenIn,
        address tokenOut,
        uint256 amountIn
    );

    constructor(address _minter) Ownable(msg.sender) {
        require(_minter != address(0), "DexInterface: Minter address cannot be zero");
        minter = Minter(_minter);
    }

    modifier onlyListener() {
        require(msg.sender == minter.listener(), "DexInterface: Caller is not the Listener");
        _;
    }

    function setMinter(address _minter) public onlyOwner {
        require(_minter != address(0), "DexInterface: Minter address cannot be zero");
        minter = Minter(_minter);
    }

    function swap(
        address poolAddress,
        address tokenIn,
        address tokenOut,
        uint256 amountIn
    ) public {
        require(poolAddress != address(0), "DexInterface: Pool address cannot be zero");
        require(tokenIn != address(0) && tokenOut != address(0), "DexInterface: Token addresses cannot be zero");
        require(amountIn > 0, "DexInterface: Swap amountIn must be greater than zero");

        address prTokenIn = minter.getPrToken(tokenIn);
        address prTokenOut = minter.getPrToken(tokenOut);

        require(prTokenIn != address(0) && prTokenOut != address(0), "DexInterface: prERC20 tokens not mapped");

        // Transfer tokenIn from trader to this contract
        IERC20(tokenIn).transferFrom(msg.sender, address(this), amountIn);

        // Mint prTokenIn
        minter.mint(tokenIn, address(this), amountIn);

        // Approve the pool to spend prTokenIn
        IERC20(prTokenIn).approve(poolAddress, amountIn);

        // // Perform the swap
        // uint256 amountOut = IDexPool(poolAddress).swap(
        //     prTokenIn,
        //     prTokenOut,
        //     amountIn,
            
        //     address(this),
        //     bytes("") 
        // );

        // // Burn prTokenOut
        // minter.burn(prTokenOut, address(this), amountIn); // tbd - fix; set actual exchange rate




        // // Transfer tokenOut to the trader
        // IERC20(tokenOut).transfer(msg.sender, amountOut);

        emit SwapInitiated(msg.sender, poolAddress, tokenIn, tokenOut, amountIn);

        // TODO: Off-chain communication with Listener
        // 1. Notify the listener about the swap. This would typically involve emitting an event
        //    with information like:
        //    - User address
        //    - Pool address
        //    - tokenIn address
        //    - tokenOut address
        //    - amountIn
        //    - amountOut
        // 2. The listener would then:
        //    - Send token B to the trader 
        //    - Send token A to the liquidity provider 
    }
}