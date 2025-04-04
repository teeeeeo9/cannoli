const { loadConfig } = require('./config');
const { ethers } = require('ethers');
const { inspectTransaction } = require('./transactions');
// const f_sign = [
//   "function mintNewLPPosition(address user,address poolAddress,uint256 amountA,uint256 amountB,address tokenA,address tokenB) public"  
//  ]
 
async function main() {
  console.log("Starting the application...");

  let cfg;
  try {
    cfg = await loadConfig();
  } catch (err) {
    console.error(`Failed to load config: ${err}`);
    return; // Exit if config load fails
  }

  console.log('cfg :>> ', cfg);

  const LiqHubProvider = new ethers.JsonRpcProvider(cfg.LiqHubRpcUrl);
  const Rollup1Provider = new ethers.JsonRpcProvider(cfg.Rollup1RpcUrl);

  const Rollup1Signer = new ethers.Wallet(cfg.privateKey, Rollup1Provider);

  let lastBlockNumberChain1 = await LiqHubProvider.getBlockNumber();



  async function processBlocks() {
    try {
      const blockNumberChain1 = await LiqHubProvider.getBlockNumber();
      // console.log('blockNumberChain1 :>> ', blockNumberChain1);
      // console.log('lastBlockNumberChain1 :>> ', lastBlockNumberChain1);

      if (blockNumberChain1 > lastBlockNumberChain1) {
        lastBlockNumberChain1 = blockNumberChain1;
        console.log(`Searching for transaction at last processed block number on LiqHub: ${lastBlockNumberChain1}`);
        const blockChain1 = await LiqHubProvider.getBlock(lastBlockNumberChain1, true);

        if (blockChain1) {
          for (const tx of blockChain1.transactions) {
            // Skip the first transaction (index 0)
            if (blockChain1.transactions.indexOf(tx) !== 0) {
              const tx_ = await LiqHubProvider.getTransaction(tx);
              await inspectTransaction(tx_, cfg.LiqHub, Rollup1Signer, Rollup1Provider, cfg.LiqManagerRollup1);
            }
          }
        }
        
      }
    } catch (err) {
      console.error(`Error processing blocks on Chain 1: ${err}`);
    }
  }

  await processBlocks();
  setInterval(processBlocks, (cfg.pollingInterval * 1000) / 2); 
}

main();