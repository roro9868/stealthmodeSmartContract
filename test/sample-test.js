const { expect } = require("chai");
const { ethers } = require("hardhat");
const { BigNumber } = require("ethers")

const ETH = BigNumber.from(10).pow(18)

describe("EPToken Checklist", function () {

  let EPToken;
  const initialSupply = 0;
  const maxSupply = ETH.mul(10000);

  before(async () => {
    const EPTokenContract = await hre.ethers.getContractFactory("EPToken");
    EPToken = await EPTokenContract.deploy(initialSupply, maxSupply);
    await EPToken.deployed();
  });

  it("Max Supply match", async function () {
    expect(await EPToken.MAX_SUPPLY()).to.equal(maxSupply);
  });

  it("Token Owner whitelisted", async function() {
    const [owner] = await ethers.getSigners();
    const ownerWhitelisted = await EPToken.checkWhiteList(owner.address)
    expect(ownerWhitelisted).to.equal(true);
  })

  it("Mint token to owner", async function() {
    const [owner] = await ethers.getSigners();
    const beforeBalance = await EPToken.balanceOf(owner.address)
    const mintAmount = 1000;
    const tx = await EPToken.mint(owner.address, mintAmount);
    await tx.wait();
    const afterBalance = await EPToken.balanceOf(owner.address)
    expect(afterBalance).to.equal(beforeBalance + mintAmount)
  })

  it("Mint token max amount exceed", async function() {
    const [owner] = await ethers.getSigners();
    await expect(
      EPToken.mint(owner.address, maxSupply.add(100))
    ).to.be.revertedWith("total supply exceed");
  })

  it('unauthorized mint', async function() {
    const [owner] = await ethers.getSigners()
    const tx = await EPToken.setWhiteList(owner.address, false);
    await tx.wait()
    await expect(
      EPToken.mint(owner.address, 100)
    ).to.be.revertedWith("Account not whitelist to mint token");
  })

});
