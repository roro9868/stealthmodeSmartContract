const { expect } = require("chai");
const { ethers } = require("hardhat");
const { BigNumber } = require("ethers")

const ETH = BigNumber.from(10).pow(18)
const ZERO_ADDRESS = '0x0000000000000000000000000000000000000000'

describe("EPQuestion Checklist", function () {

  let token;
  let EPQuestion;

  let stakingFeeReceiver = "";
  const communityFee = 3;
  const stakingPercent = 3;

  before(async () => {
  
    const [owner, account1] = await ethers.getSigners()
    stakingFeeReceiver = account1.address

    const TokenContract = await hre.ethers.getContractFactory("TestToken");
    token = await TokenContract.deploy();
    await token.deployed();
  
    const EPQusetionContract = await hre.ethers.getContractFactory("EPIQuestion");
  
    EPQuestion = await EPQusetionContract.deploy(
      stakingFeeReceiver,
      communityFee,
      stakingPercent
    )
    await EPQuestion.deployed()
  
    const tx1 = await token.approve(EPQuestion.address, ETH.mul(1000000000000))
    tx1.wait()

    const balance = await token.balanceOf(owner.address);
    console.log('token balance', balance);
  
  });

  it("correct parameter for EQQuestion", async function () {
    expect(await EPQuestion.communityFee()).to.equal(communityFee);
    expect(await EPQuestion.stakingPercent()).to.equal(stakingPercent); 
    expect(await EPQuestion.stakingFeeReceiver()).to.equal(stakingFeeReceiver);  
  });

  it("check pausable state", async function () {
  
    expect(await EPQuestion.paused()).to.equal(false);
  
    // pause the smart contract
    const tx1 = await EPQuestion.pause()
    tx1.wait()
    expect(await EPQuestion.paused()).to.equal(true);

    // unpause the smart contract

    const tx2 = await EPQuestion.unpause()
    tx2.wait()
    expect(await EPQuestion.paused()).to.equal(false);
  
  });

  it("check add and remove asset", async function () {
    
    // by default, no asset is supported for smart contract
  
    let supported = await EPQuestion.isSupportedAsset(ZERO_ADDRESS);
    expect(supported).to.equal(false);

    supported = await EPQuestion.isSupportedAsset(token.address);
    expect(supported).to.equal(false);

    // add native token and ERC20 token

    const tx1 = await EPQuestion.setAsset(ZERO_ADDRESS, ETH)
    tx1.wait()
  
    supported = await EPQuestion.isSupportedAsset(ZERO_ADDRESS);
    expect(supported).to.equal(true);
    let assetPrice = await EPQuestion.assetMinPrice(ZERO_ADDRESS);
    expect(assetPrice).to.equal(ETH);

    const tx2 = await EPQuestion.setAsset(token.address, ETH)
    tx2.wait()

    supported = await EPQuestion.isSupportedAsset(token.address);
    expect(supported).to.equal(true);
    assetPrice = await EPQuestion.assetMinPrice(token.address);
    expect(assetPrice).to.equal(ETH);

    // remove assset

    const tx3 = await EPQuestion.removeAsset(ZERO_ADDRESS)
    const tx4 = await EPQuestion.removeAsset(token.address)
  
    tx3.wait()
    tx4.wait()

    supported = await EPQuestion.isSupportedAsset(ZERO_ADDRESS);
    expect(supported).to.equal(false);

    supported = await EPQuestion.isSupportedAsset(token.address);
    expect(supported).to.equal(false);

    // add asset back for upcoming testing
    const tx5 = await EPQuestion.setAsset(ZERO_ADDRESS, ETH)
    const tx6 = await EPQuestion.setAsset(token.address, ETH)
    tx5.wait()
    tx6.wait()

  });

  it('check recover tokens', async function() {
  
    const [owner] = await ethers.getSigners()
  
    const tx1 = await token.transfer(EPQuestion.address, ETH.mul(3));
    tx1.wait()

    let contractTokenBalance = await token.balanceOf(EPQuestion.address);
    expect(contractTokenBalance).to.equal(ETH.mul(3))

    const tx2 = await EPQuestion.receive({value: ETH})
    tx2.wait()

    let contractBalance = await owner.provider.getBalance(EPQuestion.address)
    expect(contractBalance).to.equal(ETH)

    const balanceTokenBefore = await token.balanceOf(owner.address)
    const balanceBefore = await owner.provider.getBalance(owner.address)

    const tx3 = await EPQuestion.recoverTokens(
      [
        ZERO_ADDRESS, token.address
      ]
    )
    tx3.wait()

    const balanceTokenAfter = await token.balanceOf(owner.address)
    // const balanceAfter = await owner.provider.getBalance(owner.address)

    expect(balanceTokenBefore.add(ETH.mul(3))).to.equal(balanceTokenAfter)

    // throw error due to gas consumption
    // expect(balanceBefore.add(ETH)).to.equal(balanceAfter)

    contractBalance = await owner.provider.getBalance(EPQuestion.address)
    contractTokenBalance = await token.balanceOf(EPQuestion.address)

    expect(contractBalance).to.equal(0)
    expect(contractTokenBalance).to.equal(0)

  })

  it('post question for EQQuestion contract using ERC20 token', async function() {

    // check null id questions
    const questionId = '1'
    const emptyQuestionInfo = await EPQuestion.questionsInfo(questionId)
    const emptyAddress = '0x0000000000000000000000000000000000000000'
    expect(emptyQuestionInfo.owner).to.equal(emptyAddress);

    // create a question
    const [owner] = await ethers.getSigners()
    const bountyAmonut = ETH.mul(3)
    const expireAfter = 1
    const balanceBefore = await token.balanceOf(owner.address)
    console.log('create question balance before', balanceBefore)
    const tx1 = await EPQuestion.postQuestion(token.address, questionId, bountyAmonut, expireAfter)
    tx1.wait()
    const balanceAfter = await token.balanceOf(owner.address)
    console.log('create question balance after', balanceAfter)
    expect(balanceBefore.sub(balanceAfter)).to.equal(bountyAmonut)

    const createdQuestionInfo = await EPQuestion.questionsInfo(questionId)
    expect(createdQuestionInfo.owner).to.equal(owner.address);
    expect(createdQuestionInfo.active).to.equal(true);
    expect(createdQuestionInfo.delegateAmount).to.equal(bountyAmonut);
    expect(createdQuestionInfo.asset).to.equal(token.address);

    // create duplicate question id is not allowed
    await expect(
      EPQuestion.postQuestion(token.address, questionId, bountyAmonut, expireAfter)
    ).to.be.revertedWith("duplicate question id");

    // // create duplicate question with insufficient min amount
    await expect(
      EPQuestion.postQuestion(token.address, '2', ETH.div(10), expireAfter)
    ).to.be.revertedWith("minimum question fee required");

  })

  it('post question for EQQuestion contract using native token', async function() {

    // check null id questions
    const questionId = '2'
    const emptyQuestionInfo = await EPQuestion.questionsInfo(questionId)
    const emptyAddress = '0x0000000000000000000000000000000000000000'
    expect(emptyQuestionInfo.owner).to.equal(emptyAddress);

    // create a question
    const [owner] = await ethers.getSigners()
    const bountyAmonut = ETH.mul(3)
    const expireAfter = 1
    const balanceBefore = await owner.provider.getBalance(owner.address)
    console.log('create question balance before', balanceBefore)
    const tx1 = await EPQuestion.postQuestion(
      ZERO_ADDRESS, 
      questionId,
      bountyAmonut, 
      expireAfter,
      {value: bountyAmonut}
    )
    tx1.wait()
    const balanceAfter = await owner.provider.getBalance(owner.address)
    console.log('create question balance after', balanceAfter)
    // expect(balanceBefore.sub(balanceAfter)).to.equal(bountyAmonut)

    const createdQuestionInfo = await EPQuestion.questionsInfo(questionId)
    expect(createdQuestionInfo.owner).to.equal(owner.address);
    expect(createdQuestionInfo.active).to.equal(true);
    expect(createdQuestionInfo.delegateAmount).to.equal(bountyAmonut);
    expect(createdQuestionInfo.asset).to.equal(ZERO_ADDRESS);

    // create duplicate question id is not allowed
    await expect(
      EPQuestion.postQuestion(ZERO_ADDRESS, questionId, bountyAmonut, expireAfter, {value: bountyAmonut})
    ).to.be.revertedWith("duplicate question id");

    // create duplicate question with insufficient min amount
    await expect(
      EPQuestion.postQuestion(token.address, '3', 0, expireAfter)
    ).to.be.revertedWith("minimum question fee required");

  })

  // it("adjust parameter for EQQuestion", async function () {
  //   const newFeePercent = 4
  //   const newStakingFeePercent = 4
  //   const newQuestionMintAmount = ETH.mul(2)
  //   const tx1 = await EPQuestion.adjustFeePercent(newFeePercent);
  //   await tx1.wait()
  //   expect(await EPQuestion.feePercent()).to.equal(newFeePercent);
  //   const tx2 = await EPQuestion.adjustStakingPercent(newStakingFeePercent);
  //   await tx2.wait()
  //   expect(await EPQuestion.stakingPercent()).to.equal(newStakingFeePercent);
  //   const tx3 = await EPQuestion.adjustQuestionMinAmount(newQuestionMintAmount);
  //   expect(await EPQuestion.questionMinAmount()).to.equal(newQuestionMintAmount);
  //   await tx3.wait()
  // });

  it('close question for EQQuestion', async function() { 

    const [owner, other2, other3, other4, other5] = await ethers.getSigners()
  
    const address = [other2.address, other3.address]
    const userOneRewardWeight = 30 // 30%
    const userTwoRewardWeight = 70 // 70%
    const weight = [userOneRewardWeight, userTwoRewardWeight]

    const tx2 = await EPQuestion.closeQuestion('1', address, weight);
    await tx2.wait()

    const tx3 = await EPQuestion.closeQuestion('2', [other4.address, other5.address], weight);
    await tx3.wait()

    let nativeTokenFee = await EPQuestion.communityFeeMap(ZERO_ADDRESS)
    let tokenFee = await EPQuestion.communityFeeMap(token.address)

    console.log('token fee before', nativeTokenFee.toString())
    console.log('ERC20 token fee before',tokenFee.toString())

    const tx4 = await EPQuestion.withdrawCommunityFee([
      ZERO_ADDRESS,
      token.address
    ])
    await tx4.wait()

    nativeTokenFee = await EPQuestion.communityFeeMap(ZERO_ADDRESS)
    tokenFee = await EPQuestion.communityFeeMap(token.address)

    console.log('token fee after', nativeTokenFee.toString())
    console.log('ERC20 token fee after', tokenFee.toString())

  })

})