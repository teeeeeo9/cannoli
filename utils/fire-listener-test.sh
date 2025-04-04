#!/bin/bash
. .env


# Rollup1
rollup1_rpc_url="http://13.51.107.35:8547"  
liq_hub_user_address="0x0000000000000000000000000000000000000000"
rollup1_deployer_address="0x690669515543901A754D5339ebD174E1Da2c009E"  
hub_listener_address="0x690669515543901A754D5339ebD174E1Da2c009E"  
liquidity_manager_rollup1_address="0x0B35e34e2184D93525b087680c47Bbd869650f80"
mock_pool_rollup1_address="0x3c48449E76f311Fd2141522a9b4c27b674d8e2ec"
usdc_rollup1_address="0xbab9423E4d552409C8043FCcA295E11C8c8D4952"
usdt_rollup1_address="0xb5f93549596fD22c59d110a41F7455962e037b5B"


cast send "$liquidity_manager_rollup1_address" "mintNewLPPosition(address,address,uint256,uint256,address,address)" "$liq_hub_user_address" "$mock_pool_rollup1_address" "1" "1" "$usdc_rollup1_address" "$usdt_rollup1_address"  --rpc-url "$rollup1_rpc_url" --private-key "$hub_ listener_private_key"







