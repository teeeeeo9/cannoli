#!/bin/bash
. .env


# Liquidity Hub Chain
hub_rpc_url="http://51.21.254.204:8547"
hub_deployer_address="0x81DA26B3BD6E3c9169622787f6dcE80Da2B095C4"  
hub_listener_address="0x690669515543901A754D5339ebD174E1Da2c009E"  


# Approve USDC and USDT for LiquidityHub
echo "--- Approving Tokens for LiquidityHub ---"
cast send "$usdc_address" "approve(address,uint256)" "$liquidity_hub_address" "1000000000000000000" --rpc-url "$hub_rpc_url" --private-key "$hub_deployer_private_key"
cast send "$usdt_address" "approve(address,uint256)" "$liquidity_hub_address" "1000000000000000000" --rpc-url "$hub_rpc_url" --private-key "$hub_deployer_private_key"

# Deposit
echo "--- Liquidity Provider Deposits USDC and USDT ---"
usdc_deposit_amount=100
usdt_deposit_amount=100

# Get balances before deposit
usdc_balance_before=$(cast call "$usdc_address" "balanceOf(address)(uint256)" "$hub_deployer_address" --rpc-url "$hub_rpc_url")
usdt_balance_before=$(cast call "$usdt_address" "balanceOf(address)(uint256)" "$hub_deployer_address" --rpc-url "$hub_rpc_url")
liquidity_hub_usdc_balance_before=$(cast call "$usdc_address" "balanceOf(address)(uint256)" "$liquidity_hub_address" --rpc-url "$hub_rpc_url")
liquidity_hub_usdt_balance_before=$(cast call "$usdt_address" "balanceOf(address)(uint256)" "$liquidity_hub_address" --rpc-url "$hub_rpc_url")
echo "User USDC balance before deposit: $usdc_balance_before"
echo "User USDT balance before deposit: $usdt_balance_before"
echo "LiquidityHub USDC balance before deposit: $liquidity_hub_usdc_balance_before"
echo "LiquidityHub USDT balance before deposit: $liquidity_hub_usdt_balance_before"


cast send "$liquidity_hub_address" "deposit(address[],uint256[])" "[$usdc_address,$usdt_address]" "[$usdc_deposit_amount,$usdt_deposit_amount]" --rpc-url "$hub_rpc_url" --private-key "$hub_deployer_private_key"

# Get balances after deposit
usdc_balance_after=$(cast call "$usdc_address" "balanceOf(address)(uint256)" "$hub_deployer_address" --rpc-url "$hub_rpc_url")
usdt_balance_after=$(cast call "$usdt_address" "balanceOf(address)(uint256)" "$hub_deployer_address" --rpc-url "$hub_rpc_url")
liquidity_hub_usdc_balance_after=$(cast call "$usdc_address" "balanceOf(address)(uint256)" "$liquidity_hub_address" --rpc-url "$hub_rpc_url")
liquidity_hub_usdt_balance_after=$(cast call "$usdt_address" "balanceOf(address)(uint256)" "$liquidity_hub_address" --rpc-url "$hub_rpc_url")
echo "User USDC balance after deposit: $usdc_balance_after"
echo "User USDT balance after deposit: $usdt_balance_after"
echo "LiquidityHub USDC balance after deposit: $liquidity_hub_usdc_balance_after"
echo "LiquidityHub USDT balance after deposit: $liquidity_hub_usdt_balance_after"

# Mint LP on Rollup 1
echo "--- Liquidity Provider Mints LP on Rollup 1 ---"
mint_amounts1="50,50"
mint_chains1="1,1"   
mint_pools1="$mock_pool_rollup1_address,$mock_pool_rollup1_address" # Using mock pool address for simplicity

cast send "$liquidity_hub_address" "mintLP(uint256[],address[],uint256[],address[])" "[$mint_amounts1]" "[$usdc_address,$usdt_address]" "[$mint_chains1]" "[$mint_pools1]" --rpc-url "$hub_rpc_url" --private-key "$hub_deployer_private_key"


# Burn LP on Rollup 1
echo "--- Liquidity Provider Burns LP on Rollup 1 ---"
burn_amounts1="25,25"
burn_chains1="1,1"
burn_pools1="$mock_pool_rollup1_address,$mock_pool_rollup1_address"

cast send "$liquidity_hub_address" "burnLP(uint256[],uint256[],address[])" "[$burn_amounts1]" "[$burn_chains1]" "[$burn_pools1]" --rpc-url "$hub_rpc_url" --private-key "$hub_deployer_private_key"



# Withdraw from Liquidity Hub
echo "--- Liquidity Provider Withdraws from Liquidity Hub ---"
usdc_withdraw_amount=50
usdt_withdraw_amount=50

# Get balances before withdraw
usdc_balance_before_withdraw=$(cast call "$usdc_address" "balanceOf(address)(uint256)" "$hub_deployer_address" --rpc-url  "$hub_rpc_url")
usdt_balance_before_withdraw=$(cast call "$usdt_address" "balanceOf(address)(uint256)" "$hub_deployer_address" --rpc-url  "$hub_rpc_url")
liquidity_hub_usdc_balance_before_withdraw=$(cast call "$usdc_address" "balanceOf(address)(uint256)" "$liquidity_hub_address" --rpc-url "$hub_rpc_url")
liquidity_hub_usdt_balance_before_withdraw=$(cast call "$usdt_address" "balanceOf(address)(uint256)" "$liquidity_hub_address" --rpc-url "$hub_rpc_url")

echo "User USDC balance before withdraw: $usdc_balance_before_withdraw"
echo "User USDT balance before withdraw: $usdt_balance_before_withdraw"
echo "LiquidityHub USDC balance before withdraw: $liquidity_hub_usdc_balance_before_withdraw"
echo "LiquidityHub USDT balance before withdraw: $liquidity_hub_usdt_balance_before_withdraw"

cast send "$liquidity_hub_address" "withdraw(address,uint256)" "$usdc_address" "$usdc_withdraw_amount" --rpc-url "$hub_rpc_url" --private-key "$hub_deployer_private_key"
cast send "$liquidity_hub_address" "withdraw(address,uint256)" "$usdt_address" "$usdt_withdraw_amount" --rpc-url "$hub_rpc_url" --private-key "$hub_deployer_private_key"

# Get balances after withdraw
usdc_balance_after_withdraw=$(cast call "$usdc_address" "balanceOf(address)(uint256)" "$hub_deployer_address" --rpc-url  "$hub_rpc_url")
usdt_balance_after_withdraw=$(cast call "$usdt_address" "balanceOf(address)(uint256)" "$hub_deployer_address" --rpc-url  "$hub_rpc_url")
liquidity_hub_usdc_balance_after_withdraw=$(cast call "$usdc_address" "balanceOf(address)(uint256)" "$liquidity_hub_address" --rpc-url "$hub_rpc_url")
liquidity_hub_usdt_balance_after_withdraw=$(cast call "$usdt_address" "balanceOf(address)(uint256)" "$liquidity_hub_address" --rpc-url "$hub_rpc_url")

echo "User USDC balance after withdraw: $usdc_balance_after_withdraw"
echo "User USDT balance after withdraw: $usdt_balance_after_withdraw"
echo "LiquidityHub USDC balance after withdraw: $liquidity_hub_usdc_balance_after_withdraw"
echo "LiquidityHub USDT balance after withdraw: $liquidity_hub_usdt_balance_withdraw"

# --- Trader Flow ---

# Approve USDC for DexInterface on Rollup 1
echo "--- Trader Approves USDC for DexInterface on Rollup 1 ---"
cast send "$usdc_rollup1_address" "approve(address,uint256)" "$dex_interface_rollup1_address" "1000000000000000000" --rpc-url "$rollup1_rpc_url" --private-key "$rollup1_deployer_private_key" 

# Trader Swaps USDC for USDT on Rollup 1
echo "--- Trader Swaps USDC for USDT on Rollup 1 ---"
usdc_swap_amount=10

# Get balances before swap
usdc_balance_before_swap=$(cast call "$usdc_rollup1_address" "balanceOf(address)(uint256)" "$rollup1_deployer_address" --rpc-url "$rollup1_rpc_url")
usdt_balance_before_swap=$(cast call "$usdt_rollup1_address" "balanceOf(address)(uint256)" "$rollup1_deployer_address" --rpc-url "$rollup1_rpc_url")

echo "User USDC balance before swap: $usdc_balance_before_swap"
echo "User USDT balance before swap: $usdt_balance_before_swap"

cast send "$dex_interface_rollup1_address" "swap(address,address,address,uint256)" "$mock_pool_rollup1_address" "$usdc_rollup1_address" "$usdt_rollup1_address" "$usdc_swap_amount"  --rpc-url "$rollup1_rpc_url" --private-key "$rollup1_deployer_private_key" 

# Get balances after swap
usdc_balance_after_swap=$(cast call "$usdc_rollup1_address" "balanceOf(address)(uint256)" "$rollup1_deployer_address" --rpc-url "$rollup1_rpc_url")
usdt_balance_after_swap=$(cast call "$usdt_rollup1_address" "balanceOf(address)(uint256)" "$rollup1_deployer_address" --rpc-url "$rollup1_rpc_url")

echo "User USDC balance after swap: $usdc_balance_after_swap"
echo "User USDT balance after swap: $usdt_balance_after_swap"