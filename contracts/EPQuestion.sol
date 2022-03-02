// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "@openzeppelin/contracts/access/Ownable.sol";
import "./EpInterface.sol";
import "hardhat/console.sol";


contract EPQuestion is Ownable  {

    struct Question { 
        address owner;
        bool active;
        uint256 startBlock;
        uint256 delegateAmount;
    }

    mapping(string => Question) public questionsInfo;

    uint256 public feePercent;
    uint256 public stakingPercent;
    uint256 public questionMinAmount;
    uint256 public cumulatedFee;
    uint256 public cancelInterval;

    address public stakingPool;
    ERC20 private token;

    constructor(
        address _tokenAddress, 
        address _stakePoolAddress,
        uint256 _questionMinAmount,
        uint256 _feePercent,
        uint256 _stakingPercent,
        uint256 _blockInterval
    ) {
        token = ERC20(_tokenAddress);
        stakingPool = _stakePoolAddress;
        questionMinAmount = _questionMinAmount;
        feePercent = _feePercent;
        stakingPercent = _stakingPercent;
        cancelInterval = _blockInterval;
    }

    function verify(string memory _message, bytes memory _sig) internal view returns (bool) {
        bytes32 messageHash = getMessageHash(_message);
        bytes32 ethSignMessage = getEthSignedMessageHash(messageHash);
        return recover(ethSignMessage, _sig) == owner();
    }

    function getMessageHash(string memory _message) public pure returns (bytes32) {
        return keccak256(abi.encodePacked(_message));
    }

    function getEthSignedMessageHash(bytes32 _messageHash) public pure returns (bytes32) {
        return keccak256(abi.encodePacked("\x19Hi:\n32", _messageHash));
    }

    function recover(bytes32 _ethSignedMessageHash, bytes memory _sig) public pure returns (address) {
        (bytes32 r, bytes32 s, uint8 v) = _split(_sig);
        return ecrecover(_ethSignedMessageHash, v, r, s);
    }

    function _split(bytes memory _sig) internal pure returns (bytes32 r, bytes32 s, uint8 v) {
        require(_sig.length == 65, "invalid sigature length");
        assembly {
            r := mload(add(_sig, 32))
            s := mload(add(_sig, 64))
            v := byte(0, mload(add(_sig, 96)))
        } 
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

    function adjustCancelInterval(uint256 blockInterval) public onlyOwner {
        cancelInterval = blockInterval;
        emit parameterAdjusted("cancelInterval", blockInterval);
    }

    function withdrawTeamFee() public onlyOwner {
        token.approve(address(this), cumulatedFee);
        token.transferFrom(address(this), msg.sender, cumulatedFee);
        cumulatedFee = 0;
        token.approve(address(this), 0);
    }

    function postQuestion(string memory id, uint256 amount) public {
        require(token.balanceOf(msg.sender) >= amount, "Insufficnet amount to delegate");
        require(amount >= questionMinAmount, "minimum question fee required");
        require(questionsInfo[id].owner == address(0), "duplicate question id");
        token.transferFrom(msg.sender, address(this), amount);
        questionsInfo[id].owner = msg.sender;
        questionsInfo[id].active = true;
        questionsInfo[id].delegateAmount = amount;
        questionsInfo[id].startBlock = block.number;
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
        uint256 distributedReward = 0;
        for(uint i = 0; i < account.length; i++) {
            require(weight[i] <= 100, "Invalid weight parameters");
            require(account[i] != msg.sender, "Owner cannot claim reward itself");
            uint256 userRewarded = rewardAmount * weight[i] / 100;
            token.transferFrom(address(this), account[i], userRewarded);
            distributedReward += userRewarded;
        }
        require(rewardAmount == distributedReward, "Rewards did not all distributed");
        token.transferFrom(address(this), stakingPool, stakingReserved);
        token.approve(address(this), 0);
        emit questionClosed(id);
    }

    function cancelQuestion(string memory id, string memory _message, bytes memory _sig) public {
        // signature verify
        // require(verify(_message, _sig), "Invalid signature from owner");
        
        require(questionsInfo[id].owner == msg.sender, 'invalid question creator');
        require(questionsInfo[id].active, "Question closed");
        require(block.number - questionsInfo[id].startBlock >= cancelInterval, "cancel interval for question not reached");
        questionsInfo[id].active = true;
        uint256 delegateAmount = questionsInfo[id].delegateAmount;
        token.transferFrom(address(this), msg.sender, delegateAmount);
        emit questionCanceled(id);
    }

    event parameterAdjusted(string name, uint256 amount);
    event questionCreated(string id, uint256 amount);
    event questionClosed(string id);
    event questionCanceled(string id);


}