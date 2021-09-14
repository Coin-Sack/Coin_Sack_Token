const HDWalletProvider = require('@truffle/hdwallet-provider');

const fs = require('fs');
const mnemonic = fs.readFileSync(".secret").toString().trim();
const bscscan = fs.readFileSync(".bscscan").toString().trim();

module.exports = {
  networks: {
    testnet: {
      provider: () => new HDWalletProvider(mnemonic, 'https://data-seed-prebsc-1-s1.binance.org:8545/'),
      network_id: 97,
      confirmations: 3,
      skipDryRun: true,
      timeoutBlocks: 200,
      gas: 20099999
    },
    mainnet: {
      provider: () => new HDWalletProvider(mnemonic, 'https://bsc-dataseed1.binance.org'),
      network_id: 56,
      confirmations: 7,
      skipDryRun: true,
      timeoutBlocks: 200,
      gas: 20099999
    },
  },
  mocha: {},
  compilers: {
    solc: {
      version: "^0.8.7",
      docker: false,
      settings: {
        optimizer: {
          enabled: true,
          runs: 200
        },
        evmVersion: "constantinople"
      }
    }
  },
  db: {
    enabled: false
  },
  plugins: [
    'truffle-plugin-verify'
  ],
  api_keys: {
    bscscan: bscscan
  }
};
