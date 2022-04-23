// We require the Hardhat Runtime Environment explicitly here. This is optional
// but useful for running the script in a standalone fashion through `node <script>`.
//
// When running the script with `npx hardhat run <script>` you'll find the Hardhat
// Runtime Environment's members available in the global scope.
const hre = require("hardhat");
const { BigNumber } = require("ethers")

const ETH = BigNumber.from(10).pow(18)

async function main() {
  // Hardhat always runs the compile task when running scripts with its command
  // line interface.
  //
  // If this script is run directly using `node` you may want to call compile
  // manually to make sure everything is compiled
  // await hre.run('compile');

  // We get the contract to deploy
  // const EPTokenContract = await hre.ethers.getContractFactory("EPToken");
  // const name = 'EPIST'
  // const symbol = 'EPIST'
  // const supply = '10000000000000'
  // const EPToken = await EPTokenContract.deploy(name, symbol, supply);
  // await EPToken.deployed();
  // console.log("EPToken contract deployed to:", EPToken.address);

  const EPToken = '0x5742717916b30B223FD8b7A9d1b99c8074859848'
  const stakingPoolAddress = '0xE17994c9bc4Db9fd53401c9eF5e3ecd41FFbFe5a'
  const questionMinAmount = ETH;
  const feePercent = 3;
  const stakingPercent = 3;
  const EPQuestionContract = await hre.ethers.getContractFactory("EPQuestion");
  const EPQuestion = await EPQuestionContract.deploy(
    EPToken, 
    stakingPoolAddress,
    questionMinAmount,
    feePercent,
    stakingPercent,
  )
  await EPQuestion.deployed()
  console.log("EPQuestion contract deployed to:", EPQuestion.address);

}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
});
