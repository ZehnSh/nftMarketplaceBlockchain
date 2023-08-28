/** @type import('hardhat/config').HardhatUserConfig */
require("@nomicfoundation/hardhat-toolbox");
require('dotenv').config();

const MUMBAI_URL = process.env.MUMBAI_RPC;
const PRIVATE_KEY = process.env.PRIVATE_KEY;
module.exports = {
  solidity: "0.8.19",
  networks: {
    mumbai: {
      url: MUMBAI_URL,
      accounts: [PRIVATE_KEY],
    }
  },
  etherscan: {
    apiKey: "3UWCST3ESRTHCD19FU4HIH5WYNCNG2SDVT",
  }
};