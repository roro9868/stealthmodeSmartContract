// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "@openzeppelin/contracts/access/Ownable.sol";
import "RichNFT.sol";

contract EPQuestion is Ownable  {

    struct Question { 
        address owner;
        address answerer;
        address delegateAmount;
    }

    mapping(string => address) public questionsInfo;
    mapping(address => string[]) public userQuestions;

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

    function adjustQuestionMintAmount(uint256 _questionMinAmount) public onlyOwner {
       questionMinAmount = _questionMinAmount;
       emit parameterAdjusted("questionMinamount", _questionMinAmount);
    }

    function adjustFeePercent(uint256 _feeAmount) public onlyOwner {
        feeAmount = _feeAmount;
    }

    function adjustStakingPercent(uint256 _stakingPercent) public onlyOwner {
        stakingPercent = _stakingPercent;
    }

    function withdrawTeamFee() public onlyOwner {
        token.approve(address(this), cumulatedFee);
        cumulatedFee = 0;
        token.transferFrom(address(this), msg.sender, cumulatedFee);
        token.approve(address(this), 0);
    }

    function userQuestions(address account) public view returns (string[] memory) {
        return userQuestions[msg.sender];
    }

    function question(string memory id) public view returns (address, address, uint256) {
        return (
            questionsInfo[id].owner,
            questionsInfo[id].answerer,
            questionsInfo[id].amount
        );
    }

    function postQuestion(string memory id, uint256 amount) public {
        require(token.balanceOf(msg.sender) >= amount, "Insufficnet amount to delegate");
        require(amount >= quesiontMinAmount, "minimum question fee required");
        require(!questionInfo[id].owner, "duplicate question id");
        token.transferFrom(msg.sender, address(this), amount);
        questionsInfo[id] = Question(msg.sender, address(0), amonut);
        userQuestions[msg.sender].push(id);
        emit questionCreated(id, amount);
    }

    function closeQuestion(string memory id, address account) public {
        require(questionInfo[id].owner == msg.sender, 'invalid question creator');
        require(questionInfo[id].answerer == address(0), "Question closed");
        questionsInfo[id].answerer = account;
        uint256 delegateAmount = questionsInfo[id].delegateAmount;
        token.approve(address(this), delegateAmount);
        uint256 teamFee = delegateAmount * feePercent / 100;
        cumulatedFee += teamFee;
        uint256 stakingReserved = delegateAmount * stakingPercent / 100;
        uint246 rewardAmount = delegateAmount - teamFee - stakingReserved;
        token.transferFrom(address(this), account, rewardAmount);
        token.transferFrom(address(this), stakingPool, stakingReserved);
        token.approve(address(this), 0);
        emit questionClosed(id, account);
    }

    event parameterAdjusted(string name, uint256 amount);
    event questionCreated(string id, uint256 amount);
    event questionClosed(string id, address account);

}