// SPDX-License-Identifier: CC0-1.0
pragma solidity ^0.8.19;

import {Script, console} from "forge-std/Script.sol";
import {MockERC20, PromiseERC20} from "../src/MockContracts.sol";

contract Setup is Script {
    function run() external {
        vm.startBroadcast();

        MockERC20 usdc = new MockERC20("USD Coin", "USDC", 6);
        MockERC20 usdt = new MockERC20("Tether USD", "USDT", 6);
        MockERC20 weth = new MockERC20("Wrapped Ether", "WETH", 18);
        MockERC20 wbtc = new MockERC20("Wrapped Bitcoin", "WBTC", 8);

        PromiseERC20 prUSDC = new PromiseERC20("Promised USD Coin", "prUSDC", 6);
        PromiseERC20 prUSDT = new PromiseERC20("Promised Tether USD", "prUSDT", 6);
        PromiseERC20 prWETH = new PromiseERC20("Promised Wrapped Ether", "prWETH", 18);
        PromiseERC20 prWBTC = new PromiseERC20("Promised Wrapped Bitcoin", "prWBTC", 8);

        MockUniswapV2Factory factory = new MockUniswapV2Factory();

        address usdcUsdtPair = factory.createPair(address(prUSDC), address(prUSDT));
        address usdcWethPair = factory.createPair(address(prUSDC), address(prWETH));

        vm.stopBroadcast();

        console.log("USDC:", address(usdc));
        console.log("USDT:", address(usdt));
        console.log("WETH:", address(weth));
        console.log("WBTC:", address(wbtc));
        console.log("prUSDC:", address(prUSDC));
        console.log("prUSDT:", address(prUSDT));
        console.log("prWETH:", address(prWETH));
        console.log("prWBTC:", address(prWBTC));
        console.log("Factory:", address(factory));
        console.log("USDC-USDT Pair:", usdcUsdtPair);
        console.log("USDC-WETH Pair:", usdcWethPair);
    }
}