require("@nomiclabs/hardhat-waffle");
require("@nomiclabs/hardhat-etherscan");

const PRIVATE_KEY = process.env.ACCOUNT_PRIVATE_KEY
const RINKEBY_KEY = process.env.RINKEBY_API
const INFURA_ID = process.env.INFURA_ID

// This is a sample Hardhat task. To learn how to create your own go to
// https://hardhat.org/guides/create-task.html
task("accounts", "Prints the list of accounts", async (taskArgs, hre) => {
  const accounts = await hre.ethers.getSigners();
  for (const account of accounts) {
    console.log(account.address);
  }
});

// You need to export an object to set up your config
// Go to https://hardhat.org/config/ to learn more

/**
 * @type import('hardhat/config').HardhatUserConfig
 */
 module.exports = {
  solidity: {
    version: "0.8.4",
    settings: {
      optimizer: {
        enabled: true,
        runs: 1000,
      },
    },
  },
  networks: {
    rinkeby: {
      url: `https://rinkeby.infura.io/v3/${INFURA_ID}`,
      accounts: [PRIVATE_KEY]
    }
  },
  etherscan: {
    apiKey: {
      rinkeby: RINKEBY_KEY,
      polygonMumbai: "YOUR_POLYGONSCAN_API_KEY",
    }
  }
}
