// SPDX-License-Identifier: CC0-1.0
pragma solidity ^0.8.19;

import { Script, console } from "forge-std/Script.sol";
import {Minter, LiquidityManager, TradingInterface} from "../src/RollupContracts.sol";

contract DeployRollupContracts is Script {
    function run() external {
        vm.startBroadcast();

        Minter minter = new Minter(0x0000000000000000000000000000000000000000); 

        LiquidityManager liquidityManager = new LiquidityManager(
            0x0000000000000000000000000000000000000000, 
            0x0000000000000000000000000000000000000000, 
            0x0000000000000000000000000000000000000000, 
            address(minter)
        );

        TradingInterface tradingInterface = new TradingInterface(
            address(minter),
            address(liquidityManager)
        );

        minter.setPromiseToken(USDC, address(prUSDC));
        minter.setPromiseToken(USDT, address(prUSDT));
        minter.setPromiseToken(WETH, address(prWETH));
        minter.setPromiseToken(WBTC, address(prWBTC));

        vm.stopBroadcast();

        console.log("Minter:", address(minter));
        console.log("LiquidityManager:", address(liquidityManager));
        console.log("TradingInterface:", address(tradingInterface));
    }
}