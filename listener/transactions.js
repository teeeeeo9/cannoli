const { ethers } = require('ethers');

const ABI_source_chain = [
  "function mintLP(uint256[] memory amounts, address[] memory tokens, uint256[] memory chains, address[] memory pools) public"  
 ]

const ABI_receiving_chain = [
 "function mintNewLPPosition(address user, address poolAddress, uint256 amount, address tokenA, address tokenB) public"  
]

async function inspectTransaction(tx, LiqHub, chain2Signer, chain2Provider, chain2ContractAddress) {
  try {
    console.log('tx :>> ', tx);

    if (!tx) {
      console.error("Error: Transaction object is undefined.");
      return;
    }

    if (tx.hash) {
      console.log(`Transaction Hash: ${tx.hash}`);
    } else {
      console.error("Error: Transaction hash is undefined.");
      return; // Exit if no hash
    }

    if (tx.to && tx.to.toLowerCase() === LiqHub.toLowerCase()) { // Check TO address on Chain 1
      if (tx.data && tx.data !== '0x') {
        try {
          const iface = new ethers.Interface(ABI_source_chain);
          const decodedData = iface.parseTransaction({ data: tx.data });

          if (decodedData && decodedData.name === "mintLP") { // Check function name
            console.log("  Decoded Data:", decodedData);
            console.log(`  Parameter: amounts = ${decodedData.args.amounts}`);
            console.log(`  Parameter: tokens = ${decodedData.args.tokens}`);
            console.log(`  Parameter: chains = ${decodedData.args.chains}`);
            console.log(`  Parameter: pools = ${decodedData.args.pools}`);

            console.log(`  Value: ${tx.value ? ethers.formatEther(tx.value) + ' ETH' : 'No value provided'}`);
            console.log(`  From: ${tx.from}`);
            console.log(`  To: ${tx.to ? tx.to : 'Contract Creation'}`);
            console.log("---------------------------------------------------------------------------------");

            // Send transaction to the rollup
            try {
              const tx2 = await chain2Signer.sendTransaction({
                to: chain2ContractAddress,
                data: iface.encodeFunctionData("mintNewLPPosition", [tx.from, decodedData.args.pools[0], decodedData.args.amounts[0], decodedData.args.tokens[0], decodedData.args.tokens[1]] ),
                value: 0
              });
              console.log("Transaction sent to Chain 2. Hash:", tx2.hash);

            } catch (sendError) {
              console.error("Error sending transaction to Chain 2:", sendError);
            }

          } else {
            console.log("  Out of scope: Transaction not a setValue call");
          }
        } catch (decodeError) {
          console.error(`Error decoding data: ${decodeError}`);
          console.log("  Data: ", tx.data);
          console.log("  Out of scope: Decoding error");
        }
      } else {
        console.log("  Data: No data provided");
        console.log("  Out of scope: No data");
      }
    } else {
      console.log(`  To: ${tx.to ? tx.to : 'Contract Creation'}`);
      console.log("  Out of scope: Wrong TO address");
    }
  } catch (err) {
    console.error(`Error inspecting transaction ${tx ? tx.hash : 'unknown'}: ${err}`);
  }
}

module.exports = {
  inspectTransaction,
};