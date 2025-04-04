const fs = require('fs');
const path = require('path');
const dotenv = require('dotenv');

async function loadConfig() {
  try {
    const data = await fs.promises.readFile(path.join(__dirname, 'config', 'config.json'), 'utf-8');
    const cfg = JSON.parse(data);
    cfg.privateKey = process.env.rollup1_deployer_private_key;
    return cfg;
  } catch (err) {
    throw new Error(`Error reading config file: ${err}`);
  }
}

module.exports = {
  loadConfig,
};