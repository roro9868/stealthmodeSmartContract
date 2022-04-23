// SPDX-License-Identifier: MIT

pragma solidity ^0.8.7;

import "@openzeppelin/contracts/access/Ownable.sol";
import "./EpInterface.sol";

/*
@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@(((((@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
@@@@@@@@@@@@@@@@@@@@@@@@@@@@@(((((((((((((((((((((((@@@@@@@@@@@@@@@@@@@@@@@@@@@@
@@@@@@@@@@@@@@@@@@@@@@@@@(((((((((((((((((((((((((((((((@@@@@@@@@@@@@@@@@@@@@@@@
@@@@@@@@@@@@@@@@@@@@@@(((((((((((((((((((((((((((((((((((((@@@@@@@@@@@@@@@@@@@@@
@@@@@@@@@@@@@@@@@@@@(((((((((((((((((((((((((((((((((((((((((@@@@@@@@@@@@@@@@@@@
@@@@@@@@@@@@@@@@@@(((((((@@@@@@@@@@@@#(((((@@@@@@@@@@@@@(((((((@@@@@@@@@@@@@@@@@
@@@@@@@@@@@@@@@@@((((%@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@(((((@@@@@@@@@@@@@@@@
@@@@@@@@@@@@@@@@((((@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@((((@@@@@@@@@@@@@@@
@@@@@@@@@@@@@@@((((@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@(((#@@@@@@@@@@@@@@
@@@@@@@@@@@@@@@(((@@@@@@@@@(((((((@@@@@@@@@@@@#(((((((@@@@@@@@@(((@@@@@@@@@@@@@@
@@@@@@@@@@@@@@@(((@@@@@@@@(((((((((@@@@@@@@@@@(((((((((@@@@@@@@(((@@@@@@@@@@@@@@
@@@@@@@@@@@@@@@(((@@@@@@@@@(((((((@@@@@@@@@@@@@(((((((@@@@@@@@@(((@@@@@@@@@@@@@@
@@@@@@@@@@@@@@@(((@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@((((@@@@@@@@@@@@@@
@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@(((((@@@@@@@@@@@@@@
@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@(((((((@@@@@@@@@@@@@@
@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@(((((((((@@@@@@@@@@@@@@@
@@@@@@@@@@@@@@@@@@@@@@@@(((((((((((((((((((((((((((((((((((((((((@@@@@@@@@@@@@@@
@@@@@@@@@@@@@@@@@@@@((((((((((((((((((((((((((((((((((((((((((((@@@@@@@@@@@@@@@@
@@@@@@@@@@@@@@@@@((((((((((((((((((((((((((((((((((((((((((((((@@@@@@@@@@@@@@@@@
@@@@@@@@@@@@@@@@((((((((((((((((((((((((((((((((((((((((((((((@@@@@@@@@@@@@@@@@@
@@@@@@@@@@@@@@@((((((((((((((((((((((((((((((((((((((((((((((@@@@@@@@@@@@@@@@@@@
@@@@@@@@@@@@@@@(((((((((((((((((((((((((((((((((((((((((((((@@@@@@@@@@@@@@@@@@@@
@@@@@@@@@@@@@@@(((((((((((((((((((((((((((((((((((((((((((%@@@@@@@@@@@@@@@@@@@@@
@@@@@@@@@@@@@@@((((((((((((((((((((((((((((((((((((((((((@@@@@@@@@@@@@@@@@@@@@@@
@@@@@@@@@@@@@@@((((((((((((((((((((((((((((((((((((((((@@@@@@@@@@@@@@@@@@@@@@@@@
@@@@@@@@@@@@@@@((((((((((((((((((((((((((((((((((((((@@@@@@@@@@@@@@@@@@@@@@@@@@@
@@@@@@@@@@@@@@@(((((((((((((((((((((((((((((((((((#@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
@@@@@@@@@@@@@@@(((((((((((((((((((((((((((((((((@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
@@@@@@@@@@@@@@@((((((((((((((((((((((((((((((@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
@@@@@@@@@@@@@@@((((((((((((((((((((((((((@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
@@@@@@@@@@@@@@@((((((((((((((((((((((@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
@@@@@@@@@@@@@@@#((((((((((((((#@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
EEEEEEEEEEEEEEEEEEEEEEPPPPPPPPPPPPPPPPP   IIIIIIIIII   SSSSSSSSSSSSSSS TTTTTTTTTTTTTTTTTTTTTTT
E::::::::::::::::::::EP::::::::::::::::P  I::::::::I SS:::::::::::::::ST:::::::::::::::::::::T
E::::::::::::::::::::EP::::::PPPPPP:::::P I::::::::IS:::::SSSSSS::::::ST:::::::::::::::::::::T
EE::::::EEEEEEEEE::::EPP:::::P     P:::::PII::::::IIS:::::S     SSSSSSST:::::TT:::::::TT:::::T
  E:::::E       EEEEEE  P::::P     P:::::P  I::::I  S:::::S            TTTTTT  T:::::T  TTTTTT
  E:::::E               P::::P     P:::::P  I::::I  S:::::S                    T:::::T        
  E::::::EEEEEEEEEE     P::::PPPPPP:::::P   I::::I   S::::SSSS                 T:::::T        
  E:::::::::::::::E     P:::::::::::::PP    I::::I    SS::::::SSSSS            T:::::T        
  E:::::::::::::::E     P::::PPPPPPPPP      I::::I      SSS::::::::SS          T:::::T        
  E::::::EEEEEEEEEE     P::::P              I::::I         SSSSSS::::S         T:::::T        
  E:::::E               P::::P              I::::I              S:::::S        T:::::T        
  E:::::E       EEEEEE  P::::P              I::::I              S:::::S        T:::::T        
EE::::::EEEEEEEE:::::EPP::::::PP          II::::::IISSSSSSS     S:::::S      TT:::::::TT      
E::::::::::::::::::::EP::::::::P          I::::::::IS::::::SSSSSS:::::S      T:::::::::T      
E::::::::::::::::::::EP::::::::P          I::::::::IS:::::::::::::::SS       T:::::::::T      
EEEEEEEEEEEEEEEEEEEEEEPPPPPPPPPP          IIIIIIIIII SSSSSSSSSSSSSSS         TTTTTTTTTTT      
*/

contract EPQuestion is Ownable  {

    struct Question { 
        address owner;
        bool active;
        uint256 startBlock;
        uint256 expireAfter;
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
        token.transferFrom(address(this), msg.sender, cumulatedFee);
        cumulatedFee = 0;
    }

    function postQuestion(string memory id, uint256 amount, uint256 expireAfter) public {
        require(token.balanceOf(msg.sender) >= amount, "Insufficnet amount to delegate");
        require(amount >= questionMinAmount, "minimum question fee required");
        require(questionsInfo[id].owner == address(0), "duplicate question id");
        token.transferFrom(msg.sender, address(this), amount);
        questionsInfo[id].owner = msg.sender;
        questionsInfo[id].active = true;
        questionsInfo[id].delegateAmount = amount;
        questionsInfo[id].startBlock = block.number;
        questionsInfo[id].expireAfter = expireAfter;
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
        emit questionClosed(id);
    }

    function closeExpiredQuestion(string[] memory ids) external onlyOwner {
        for(uint i = 0; i < ids.length; i++) {
            string memory id = ids[i];
            require(questionsInfo[id].active, "Question closed");
            require(
                questionsInfo[id].startBlock + questionsInfo[id].expireAfter <= block.number, 
                'Question not expired yet'
            );
            questionsInfo[id].active = false;
            token.approve(address(this), questionsInfo[id].delegateAmount);
            token.transferFrom(address(this), stakingPool, questionsInfo[id].delegateAmount);
            emit questionExpired(id);
        }
    }

    event parameterAdjusted(string name, uint256 amount);
    event questionCreated(string id, uint256 amount);
    event questionClosed(string id);
    event questionExpired(string id);

}