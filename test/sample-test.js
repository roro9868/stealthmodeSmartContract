const { expect } = require("chai");
const { ethers } = require("hardhat");
const { BigNumber } = require("ethers")

const ETH = BigNumber.from(10).pow(18)

describe("EPQuestion Checklist", function () {

  let EPToken;
  let EPQuestion;
  const initialSupply = 0;
  const maxSupply = ETH.mul(10000);

  let stakingPoolAddress = "";

  const questionMinAmount = ETH;
  const feePercent = 3;
  const stakingPercent = 3;

  before(async () => {
    const [owner] = await ethers.getSigners()
    const EPTokenContract = await hre.ethers.getContractFactory("EPToken");
    EPToken = await EPTokenContract.deploy("EPTOKEN", "EPTOKEN", maxSupply);
    await EPToken.deployed();
    const EPQusetionContract = await hre.ethers.getContractFactory("EPQuestion");
    EPQuestion = await EPQusetionContract.deploy(
      EPToken.address,
      EPToken.address,
      questionMinAmount,
      feePercent,
      stakingPercent
    )
    await EPQuestion.deployed()
    const tx1 = await EPToken.approve(EPQuestion.address, ETH.mul(1000000000000))
    tx1.wait()
    // const tx2 = await EPToken.mint(owner.address, ETH.mul(1000));
    // tx2.wait()
    const balance = await EPToken.balanceOf(owner.address);
    console.log('token balance', balance);
  });

  it("correct parameter for EQQuestion", async function () {
    expect(await EPQuestion.feePercent()).to.equal(feePercent);
    expect(await EPQuestion.stakingPercent()).to.equal(stakingPercent);
    expect(await EPQuestion.questionMinAmount()).to.equal(questionMinAmount);   
  });

  it("adjust parameter for EQQuestion", async function () {
    const newFeePercent = 4
    const newStakingFeePercent = 4
    const newQuestionMintAmount = ETH.mul(2)
    const tx1 = await EPQuestion.adjustFeePercent(newFeePercent);
    await tx1.wait()
    expect(await EPQuestion.feePercent()).to.equal(newFeePercent);
    const tx2 = await EPQuestion.adjustStakingPercent(newStakingFeePercent);
    await tx2.wait()
    expect(await EPQuestion.stakingPercent()).to.equal(newStakingFeePercent);
    const tx3 = await EPQuestion.adjustQuestionMinAmount(newQuestionMintAmount);
    expect(await EPQuestion.questionMinAmount()).to.equal(newQuestionMintAmount);
    await tx3.wait()
  });

  it('post question for EQQuestion', async function() {

    // check null id questions
    const questionId = '1'
    const emptyQuestionInfo = await EPQuestion.questionsInfo(questionId)
    const emptyAddress = '0x0000000000000000000000000000000000000000'
    expect(emptyQuestionInfo.owner).to.equal(emptyAddress);

    // create a question
    const [owner] = await ethers.getSigners()
    const bountyAmonut = ETH.mul(3)
    const expireAfter = 10000
    const balanceBefore = await EPToken.balanceOf(owner.address)
    console.log('create question balance before', balanceBefore)
    const tx1 = await EPQuestion.postQuestion(questionId, bountyAmonut, expireAfter)
    tx1.wait()
    const balanceAfter = await EPToken.balanceOf(owner.address)
    console.log('create question balance after', balanceAfter)
    expect(balanceBefore.sub(balanceAfter)).to.equal(bountyAmonut)

    const createdQuestionInfo = await EPQuestion.questionsInfo(questionId)
    expect(createdQuestionInfo.owner).to.equal(owner.address);
    expect(createdQuestionInfo.active).to.equal(true);
    expect(createdQuestionInfo.delegateAmount).to.equal(bountyAmonut);

    // create duplicate question id is not allowed
    await expect(
      EPQuestion.postQuestion(questionId, bountyAmonut, expireAfter)
    ).to.be.revertedWith("duplicate question id");

    // create duplicate question with insufficient min amount
    await expect(
      EPQuestion.postQuestion(questionId, ETH.div(10), expireAfter)
    ).to.be.revertedWith("minimum question fee required");

  })

  it('close question for EQQuestion', async function() { 

    const [owner, other1, other2] = await ethers.getSigners()
    const questionId = '2'
    const expireAfter = 10000
    const bountyAmonut = ETH.mul(3)
    const tx1 = await EPQuestion.postQuestion(questionId, bountyAmonut, expireAfter)
    await tx1.wait()

    const address = [other1.address, other2.address]
    const userOneRewardWeight = 30 // 30%
    const userTwoRewardWeight = 70 // 70%
    const weight = [userOneRewardWeight, userTwoRewardWeight]
    const tx2 = await EPQuestion.closeQuestion(questionId, address, weight);
    await tx2.wait()

    // verify the reward is distributed accordingly
    const stakingPercent = await EPQuestion.stakingPercent()
    const feePercent = await EPQuestion.feePercent()
    const feeToStakingPool = bountyAmonut.mul(stakingPercent).div(100)
    const feeForTeam = bountyAmonut.mul(feePercent).div(100)
    const reward = bountyAmonut.sub(feeToStakingPool).sub(feeForTeam)
    const balanceOther1 = await EPToken.balanceOf(other1.address);
    const balanceOther2 = await EPToken.balanceOf(other2.address);
    expect(balanceOther1).to.equal(reward.mul(userOneRewardWeight).div(100))
    expect(balanceOther2).to.equal(reward.mul(userTwoRewardWeight).div(100))
    expect(balanceOther1.add(balanceOther2)).to.equal(reward);

    // verify the team get the fee
    const feeToClaimForTeam = await EPQuestion.cumulatedFee()
    expect(feeToClaimForTeam).to.equal(feeForTeam)

    // verify the team can claim the fee
    const BalanceBefore = await EPToken.balanceOf(owner.address);
    const tx3 = await EPQuestion.withdrawTeamFee()
    await tx3.wait()
    const BalanceAfter = await EPToken.balanceOf(owner.address)
    expect(BalanceBefore.add(feeForTeam)).to.equal(BalanceAfter)

  })

  it('close expired question', async function() {
    
    // https://ethereum.stackexchange.com/questions/86633/time-dependent-tests-with-hardhat
  
    const questionId = '3'
    const expireAfter = 1
    const bountyAmonut = ETH.mul(3)
    const tx1 = await EPQuestion.postQuestion(questionId, bountyAmonut, expireAfter)
    await tx1.wait()

    const info = await EPQuestion.questionsInfo(questionId)
    console.log(info)

    const blockNumBefore = await ethers.provider.getBlockNumber();
    console.log(blockNumBefore)
    await ethers.provider.send('evm_mine');
    await ethers.provider.send('evm_mine');
    const blockNumAfter = await ethers.provider.getBlockNumber();
    console.log(blockNumAfter)

    const tx2 = await EPQuestion.closeExpiredQuestion([questionId])
    await tx2.wait()

  })

})