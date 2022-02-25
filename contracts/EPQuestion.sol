// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "@openzeppelin/contracts/access/Ownable.sol";
import "./EpInterface.sol";

contract EPQuestion is Ownable  {

    struct Question { 
        address owner;
        bool active;
        uint256 delegateAmount;
    }

    mapping(string => Question) public questionsInfo;

    uint256 public feePercent;
    uint256 public stakingPercent;
    uint256 public questionMinAmount;
    uint256 public cumulatedFee;

    address public stakingPool;
    ERC20 private token;

    constructor(
        address _tokenAddress, 
        address _stakePoolAddress,
        uint256 _questionMinAmount,
        uint256 _feePercent,
        uint256 _stakingPercent
    ) {
        token = ERC20(_tokenAddress);
        stakingPool = _stakePoolAddress;
        questionMinAmount = _questionMinAmount;
        feePercent = _feePercent;
        stakingPercent = _stakingPercent;
    }

    function adjustQuestionMinAmount(uint256 _questionMinAmount) public onlyOwner {
       questionMinAmount = _questionMinAmount;
       emit parameterAdjusted("questionMinAmount", _questionMinAmount);
    }

    function adjustFeePercent(uint256 _feePercent) public onlyOwner {
        feePercent = _feePercent;
        emit parameterAdjusted("feePercent", feePercent);
    }

    function adjustStakingPercent(uint256 _stakingPercent) public onlyOwner {
        stakingPercent = _stakingPercent;
        emit parameterAdjusted("stakingPercent", stakingPercent);
    }

    function withdrawTeamFee() public onlyOwner {
        token.approve(address(this), cumulatedFee);
        cumulatedFee = 0;
        token.transferFrom(address(this), msg.sender, cumulatedFee);
        token.approve(address(this), 0);
    }

    function postQuestion(string memory id, uint256 amount) public {
        require(token.balanceOf(msg.sender) >= amount, "Insufficnet amount to delegate");
        require(amount >= questionMinAmount, "minimum question fee required");
        token.transferFrom(msg.sender, address(this), amount);
        questionsInfo[id].owner = msg.sender;
        questionsInfo[id].active = true;
        questionsInfo[id].delegateAmount = amount;
        emit questionCreated(id, amount);
    }

    function closeQuestion(string memory id, address[] memory account, uint256[] memory weight) public {
        require(questionsInfo[id].owner == msg.sender, 'invalid question creator');
        require(questionsInfo[id].active, "Question closed");
        questionsInfo[id].active = false;
        uint256 delegateAmount = questionsInfo[id].delegateAmount;
        token.approve(address(this), delegateAmount);
        uint256 teamFee = delegateAmount * feePercent / 100;
        cumulatedFee += teamFee;
        uint256 stakingReserved = delegateAmount * stakingPercent / 100;
        uint256 rewardAmount = delegateAmount - teamFee - stakingReserved;
        for(uint i = 0; i < account.length; i++) {
            uint256 userRewarded = weight[i] / rewardAmount * 100;
            token.transferFrom(address(this), account[i], userRewarded);
        }
        token.transferFrom(address(this), stakingPool, stakingReserved);
        token.approve(address(this), 0);
        emit questionClosed(id);
    }

    event parameterAdjusted(string name, uint256 amount);
    event questionCreated(string id, uint256 amount);
    event questionClosed(string id);

}