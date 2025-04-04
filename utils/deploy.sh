#!/bin/bash
. .env

# --- Configuration ---

# Liquidity Hub Chain
hub_rpc_url="http://51.21.254.204:8547"
hub_deployer_address="0x81DA26B3BD6E3c9169622787f6dcE80Da2B095C4"  
hub_listener_address="0x690669515543901A754D5339ebD174E1Da2c009E"  

# Rollup Chain 1
rollup1_rpc_url="http://13.51.107.35:8547"  
rollup1_deployer_address="0x690669515543901A754D5339ebD174E1Da2c009E"  

# # Rollup Chain 2
# rollup2_rpc_url="http://127.0.0.1:8547"  
# rollup2_deployer_address="0x3C44CdD89Db6Dfe021436c617abA36eA790F586E"  

# --- Deployment ---

# Deploy Mock ERC20 Tokens (USDC, USDT) on Liquidity Hub Chain
echo "--- Deploying USDC and USDT on Liquidity Hub ---"
usdc_address=$(forge create --rpc-url "$hub_rpc_url" --private-key "$hub_deployer_private_key" src/MockERC20.sol:MockERC20 --constructor-args "USD Coin" "USDC" 18 | grep "Deployed to:" | awk '{print $NF}')
usdt_address=$(forge create --rpc-url "$hub_rpc_url" --private-key "$hub_deployer_private_key" src/MockERC20.sol:MockERC20 --constructor-args "Tether USD" "USDT" 18 | grep "Deployed to:" | awk '{print $NF}')
echo "USDC deployed to: $usdc_address on Liq.Hub"
echo "USDT deployed to: $usdt_address on Liq.Hub"


# Deploy Mock ERC20 Tokens (USDC, USDT) on Rollup1
echo "--- Deploying USDC and USDT on Liquidity Hub ---"
usdc_rollup1_address=$(forge create --rpc-url "$rollup1_rpc_url" --private-key "$rollup1_deployer_private_key" src/MockERC20.sol:MockERC20 --constructor-args "USD Coin" "USDC" 18 | grep "Deployed to:" | awk '{print $NF}')
usdt_rollup1_address=$(forge create --rpc-url "$rollup1_rpc_url" --private-key "$rollup1_deployer_private_key" src/MockERC20.sol:MockERC20 --constructor-args "Tether USD" "USDT" 18 | grep "Deployed to:" | awk '{print $NF}')
echo "USDC deployed to: $usdc_rollup1_address on Rollup1"
echo "USDT deployed to: $usdt_rollup1_address on Rollup1"

# Deploy prUSDC and prUSDT on Rollup 1
echo "--- Deploying prUSDC and prUSDT on Rollup 1 ---"
pr_usdc_rollup1_address=$(forge create --rpc-url "$rollup1_rpc_url" --private-key "$rollup1_deployer_private_key" src/prERC20.sol:prERC20 --constructor-args "Promised USDC" "prUSDC"  | grep "Deployed to:" | awk '{print $NF}')
pr_usdt_rollup1_address=$(forge create --rpc-url "$rollup1_rpc_url" --private-key "$rollup1_deployer_private_key" src/prERC20.sol:prERC20 --constructor-args "Promised USDT" "prUSDT"  | grep "Deployed to:" | awk '{print $NF}')
echo "prUSDC on Rollup 1 deployed to: $pr_usdc_rollup1_address"
echo "prUSDT on Rollup 1 deployed to: $pr_usdt_rollup1_address"

# # Deploy prUSDC and prUSDT on Rollup 2
# echo "--- Deploying prUSDC and prUSDT on Rollup 2 ---"
# pr_usdc_rollup2_address=$(forge create --rpc-url "$rollup2_rpc_url" --private-key "$rollup2_deployer_private_key" src/PrERC20.sol:PrERC20 --constructor-args "Promised USDC" "prUSDC" 18 | grep "Deployed to:" | awk '{print $NF}')
# pr_usdt_rollup2_address=$(forge create --rpc-url "$rollup2_rpc_url" --private-key "$rollup2_deployer_private_key" src/PrERC20.sol:PrERC20 --constructor-args "Promised USDT" "prUSDT" 18 | grep "Deployed to:" | awk '{print $NF}')
# echo "prUSDC on Rollup 2 deployed to: $pr_usdc_rollup2_address"
# echo "prUSDT on Rollup 2 deployed to: $pr_usdt_rollup2_address"

# Deploy LP token on Rollup 1
echo "--- Deploying mock LP token on Rollup 1 ---"
lp_rollup1_address=$(forge create --rpc-url "$rollup1_rpc_url" --private-key "$rollup1_deployer_private_key" src/LPToken.sol:LPToken --constructor-args "LP" "LP" 18 | grep "Deployed to:" | awk '{print $NF}')
echo "LP on Rollup 1 deployed to: $lp_rollup1_address"

# Deploy mock pool on Rollup 1
echo "--- Deploying MockPool on Rollup 1 ---"
mock_pool_rollup1_address=$(forge create --rpc-url "$rollup1_rpc_url" --private-key "$rollup1_deployer_private_key" src/DexPool.sol:DexPool --constructor-args "$pr_usdc_rollup1_address" "$pr_usdt_rollup1_address" "$lp_rollup1_address" | grep "Deployed to:" | awk '{print $NF}')
echo "MockPool on Rollup 1 deployed to: $mock_pool_rollup1_address"

# # Deploy MockPool on Rollup 2
# echo "--- Deploying MockPool on Rollup 2 ---"
# mock_pool_rollup2_address=$(forge create --rpc-url "$rollup2_rpc_url" --private-key "$rollup2_deployer_private_key" src/MockPool.sol:MockPool --constructor-args "$pr_usdc_rollup2_address" "$pr_usdt_rollup2_address" | grep "Deployed to:" | awk '{print $NF}')
# echo "MockPool on Rollup 2 deployed to: $mock_pool_rollup2_address"








# Deploy LiquidityHub on Liquidity Hub Chain
echo "--- Deploying LiquidityHub on Liquidity Hub ---"
liquidity_hub_address=$(forge create --rpc-url "$hub_rpc_url" --private-key "$hub_deployer_private_key" src/LiquidityHub.sol:LiquidityHub --constructor-args "$hub_deployer_address" | grep "Deployed to:" | awk '{print $NF}')
echo "LiquidityHub deployed to: $liquidity_hub_address"



# Deploy LiquidityManager on Rollup 1
echo "--- Deploying LiquidityManager on Rollup 1 ---"
liquidity_manager_rollup1_address=$(forge create --rpc-url "$rollup1_rpc_url" --private-key "$rollup1_deployer_private_key" src/LiquidityManager.sol:LiquidityManager | grep "Deployed to:" | awk '{print $NF}')
echo "LiquidityManager on Rollup 1 deployed to: $liquidity_manager_rollup1_address"

# # Deploy LiquidityManager on Rollup 2
# echo "--- Deploying LiquidityManager on Rollup 2 ---"
# liquidity_manager_rollup2_address=$(forge create --rpc-url "$rollup2_rpc_url" --private-key "$rollup2_deployer_private_key" src/LiquidityManager.sol:LiquidityManager --constructor-args "$minter_rollup2_address" | grep "Deployed to:" | awk '{print $NF}')
# echo "LiquidityManager on Rollup 2 deployed to: $liquidity_manager_rollup2_address"





# Deploy Minter on Rollup 1
echo "--- Deploying Minter on Rollup 1 ---"
minter_rollup1_address=$(forge create --rpc-url "$rollup1_rpc_url" --private-key "$rollup1_deployer_private_key" src/Minter.sol:Minter --constructor-args "$liquidity_manager_rollup1_address" "$hub_listener_address" | grep "Deployed to:" | awk '{print $NF}')
echo "Minter on Rollup 1 deployed to: $minter_rollup1_address"

# # Deploy Minter on Rollup 2
# echo "--- Deploying Minter on Rollup 2 ---"
# minter_rollup2_address=$(forge create --rpc-url "$rollup2_rpc_url" --private-key "$rollup2_deployer_private_key" src/Minter.sol:Minter --constructor-args "$rollup2_liquidity_manager_address" "$hub_listener_address" | grep "Deployed to:" | awk '{print $NF}')
# echo "Minter on Rollup 2 deployed to: $minter_rollup2_address"







# Deploy DexInterface on Rollup 1
echo "--- Deploying DexInterface on Rollup 1 ---"
dex_interface_rollup1_address=$(forge create --rpc-url "$rollup1_rpc_url" --private-key "$rollup1_deployer_private_key" src/DexInterface.sol:DexInterface --constructor-args "$minter_rollup1_address" | grep "Deployed to:" | awk '{print $NF}')
echo "DexInterface on Rollup 1 deployed to: $dex_interface_rollup1_address"

# # Deploy DexInterface on Rollup 2
# echo "--- Deploying DexInterface on Rollup 2 ---"
# dex_interface_rollup2_address=$(forge create --rpc-url "$rollup2_rpc_url" --private-key "$rollup2_deployer_private_key" src/DexInterface.sol:DexInterface --constructor-args "$minter_rollup2_address" | grep "Deployed to:" | awk '{print $NF}')
# echo "DexInterface on Rollup 2 deployed to: $dex_interface_rollup2_address"




# --- Configuration ---

# Configure Minter contracts
echo "--- Configuring Minter Contracts ---"
cast send "$minter_rollup1_address" "mapTokens(address,address)" "$usdc_rollup1_address" "$pr_usdc_rollup1_address" --rpc-url "$rollup1_rpc_url" --private-key "$rollup1_deployer_private_key"
cast send "$minter_rollup1_address" "mapTokens(address,address)" "$usdt_rollup1_address" "$pr_usdt_rollup1_address" --rpc-url "$rollup1_rpc_url" --private-key "$rollup1_deployer_private_key"
cast send "$minter_rollup1_address" "setDexInterface(address)" "$dex_interface_rollup1_address" --rpc-url "$rollup1_rpc_url" --private-key "$rollup1_deployer_private_key"
# cast send "$minter_rollup2_address" "mapTokens(address,address)" "$usdc_address" "$pr_usdc_rollup2_address" --rpc-url "$rollup2_rpc_url" --private-key "$rollup2_deployer_private_key"
# cast send "$minter_rollup2_address" "mapTokens(address,address)" "$usdt_address" "$pr_usdt_rollup2_address" --rpc-url "$rollup2_rpc_url" --private-key "$rollup2_deployer_private_key"

# Configure LiquidityHub - Add Allowed Tokens
echo "--- Configuring LiquidityHub ---"
cast send "$liquidity_hub_address" "addAllowedToken(address)" "$usdc_address" --rpc-url "$hub_rpc_url" --private-key "$hub_deployer_private_key"
cast send "$liquidity_hub_address" "addAllowedToken(address)" "$usdt_address" --rpc-url "$hub_rpc_url" --private-key "$hub_deployer_private_key"

# Configure LiquidityManager on Rollup 1
echo "--- Configuring LiquidityManager on Rollup 1 ---"
cast send "$liquidity_manager_rollup1_address" "setMinter(address)" "$minter_rollup1_address" --rpc-url "$rollup1_rpc_url" --private-key "$rollup1_deployer_private_key"

# # Configure LiquidityManager on Rollup 2
# echo "--- Configuring LiquidityManager on Rollup 2 ---"
# cast send "$liquidity_manager_rollup2_address" "setMinter(address)" "$minter_rollup2_address" --rpc-url "$rollup2_rpc_url" --private-key "$rollup2_deployer_private_key"

# # Mint USDC to trader on Rollup 1
# echo "--- Minting USDC to Trader on Rollup 1 ---"
# cast send "$usdc_address" "mint(address,uint256)" "$rollup1_deployer_address" "1000" --rpc-url "$rollup1_rpc_url" --private-key "$rollup1_deployer_private_key" 

