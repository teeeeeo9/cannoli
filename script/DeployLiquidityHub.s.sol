// SPDX-License-Identifier: CC0-1.0
pragma solidity ^0.8.19;

import { Script, console } from "forge-std/Script.sol";
import { ERC20 } from "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import {LiquidityHub} from "../src/LiquidityHub.sol";

contract DeployLiquidityHub is Script {
    function run() external {
        vm.startBroadcast();

        address USDC = address(new ERC20("USD Coin", "USDC"));
        address USDT = address(new ERC20("Tether USD", "USDT"));
        address WETH = address(new ERC20("Wrapped Ether", "WETH"));
        address WBTC = address(new ERC20("Wrapped Bitcoin", "WBTC"));

        // Deploy LiquidityHub
        LiquidityHub liquidityHub = new LiquidityHub(
            0x0000000000000000000000000000000000000000,  
            0x0000000000000000000000000000000000000000  
        );

        liquidityHub.setTokenAddresses(USDC, USDT, WETH, WBTC);

        liquidityHub.addSupportedToken(USDC);
        liquidityHub.addSupportedToken(USDT);
        liquidityHub.addSupportedToken(WETH);
        liquidityHub.addSupportedToken(WBTC);

        vm.stopBroadcast();

        console.log("LiquidityHub:", address(liquidityHub));
    }
}