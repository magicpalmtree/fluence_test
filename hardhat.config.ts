/**
 * @type import('hardhat/config').HardhatUserConfig
 */
import { task } from "hardhat/config";
import '@typechain/hardhat';
import '@nomiclabs/hardhat-ethers'
import '@nomiclabs/hardhat-waffle'

import { networks } from './hardhat.network';

task("accounts", "Prints the list of accounts", async (taskArgs, hre) => {
  const accounts = await hre.ethers.getSigners();

  for (const account of accounts) {
    console.log(account.address);
  }
});

module.exports = {
  solidity: {
    version: "0.8.9",
    settings: {
      optimizer: {
        enabled: true,
        runs: 200,
      },
    },
  },
  networks:  {
    hardhat: {
      forking: {
        url: "https://eth-mainnet.alchemyapi.io/v2/dX1QRfJit2SeEg5lbvqzI0uJK0Qz87NC",
        blockNumber: 14189520,
      }
    }
  }
  // networks
};