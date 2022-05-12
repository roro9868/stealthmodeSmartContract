// SPDX-License-Identifier: MIT

pragma solidity ^0.8.7;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/security/Pausable.sol";
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

contract EPIQuestion is Ownable, Pausable  {

    struct Question {
        address owner;
        address asset;
        bool active;
        uint256 startTimestamp;
        uint256 expireAfter;
        uint256 delegateAmount;
    }

    mapping(string => Question) public questionsInfo;

    uint256 public communityFee;
    uint256 public stakingPercent;

    mapping(address => uint256) public assetMinPrice;
    mapping(address => uint256) public communityFeeMap;

    address public stakingFeeReceiver;

    constructor( 
        address _stakingFeeReceiver,
        uint256 _communityFee,
        uint256 _stakingPercent
    ) {
        stakingFeeReceiver = _stakingFeeReceiver;
        communityFee = _communityFee;
        stakingPercent = _stakingPercent;
    }

    function pause() external onlyOwner {
        _pause();
    }

    function unpause() external onlyOwner {
        _unpause();
    }

    function setAsset(address asset, uint256 amount) external onlyOwner {
        assetMinPrice[asset] = amount;
        emit SetAsset(asset, amount);
    }

    function removeAsset(address asset) external onlyOwner {
        delete assetMinPrice[asset];
        emit RemoveAsset(asset);
    }

    function isSupportedAsset(address asset) public view returns (bool) {
        return assetMinPrice[asset] > 0;
    }

    function adjustCommunityFee(uint256 _communityFee) external onlyOwner {
        communityFee = _communityFee;
        emit parameterAdjusted("communityFee", communityFee);
    }

    function adjustStakingPercent(uint256 _stakingPercent) external onlyOwner {
        stakingPercent = _stakingPercent;
        emit parameterAdjusted("stakingPercent", stakingPercent);
    }

    function isNativeToken(address asset) internal pure returns (bool) {
        return asset == address(0);
    }

    function recoverTokens(address[] memory assets) external onlyOwner {
        for(uint i = 0; i < assets.length; i++) {
            address asset = assets[i];
            require(isSupportedAsset(asset), 'Asset not supported');
            if(isNativeToken(asset)) {
                payable(msg.sender).transfer(address(this).balance);
            } else {
                ERC20 token = ERC20(asset);
                uint256 tokenBalance = token.balanceOf(address(this));
                token.transfer(msg.sender, tokenBalance);
            }
        }
    }

    function withdrawCommunityFee(address[] memory assets) external onlyOwner {
        for(uint i = 0; i < assets.length; i++) {
            address asset = assets[i];
            require(isSupportedAsset(asset), 'Asset not supported');
            if(isNativeToken(asset)) {
                payable(msg.sender).transfer(communityFeeMap[asset]);
            } else {
                ERC20 token = ERC20(asset);
                token.transfer(msg.sender, communityFeeMap[asset]);
            }
            communityFeeMap[asset] = 0;
        }
    }

    function _createQuestion(address _asset, string memory id, uint256 amount, uint256 expireAfter) internal {
        questionsInfo[id].owner = msg.sender;
        questionsInfo[id].active = true;
        questionsInfo[id].delegateAmount = amount;
        questionsInfo[id].startTimestamp = block.timestamp;
        questionsInfo[id].expireAfter = expireAfter;
        questionsInfo[id].asset = _asset;
        emit questionCreated(id, amount);
    }


    function postQuestion(address _asset, string memory id, uint256 amount, uint256 expireAfter) payable external whenNotPaused {

        require(isSupportedAsset(_asset), 'Invalid asset');
        require(questionsInfo[id].owner == address(0), "duplicate question id");
        uint256 minPrice = assetMinPrice[_asset];

        if(isNativeToken(_asset)) {
            require(address(msg.sender).balance >= minPrice,  "Insufficient amount to delegate");
            require(msg.value == amount, 'delegate amount should equal to msg.value');
            require(msg.value >= minPrice, "minimum question fee required");
        } else {
            require(ERC20(_asset).balanceOf(msg.sender) >= assetMinPrice[_asset], "Insufficient amount to delegate");
            require(amount >= assetMinPrice[_asset], "minimum question fee required");
            ERC20(_asset).transferFrom(msg.sender, address(this), amount);
        }

        _createQuestion(_asset, id, amount, expireAfter);

    }

    function isQuestionExpired(string memory id) public view returns (bool) {
        return questionsInfo[id].startTimestamp + questionsInfo[id].expireAfter <= block.timestamp;
    }

    function closeQuestion(string memory id, address[] memory account, uint256[] memory weight) whenNotPaused public {

        require(isQuestionExpired(id), 'Question not expired');
        require(questionsInfo[id].owner == msg.sender || msg.sender == owner(), 'invalid question creator');
        require(questionsInfo[id].active, "Question closed");
        address asset = questionsInfo[id].asset;

        questionsInfo[id].active = false;
        uint256 delegateAmount = questionsInfo[id].delegateAmount;
        uint256 reservedFee = delegateAmount / 100 * communityFee;
        communityFeeMap[asset] += reservedFee;
    
        uint256 stakingReserved = delegateAmount / 100 * stakingPercent;
        uint256 rewardAmount = delegateAmount - reservedFee - stakingReserved;
        uint256 distributedReward = 0;

        if(isNativeToken(asset)) {
            payable(stakingFeeReceiver).transfer(stakingReserved);
        } else {
            ERC20(asset).transfer(stakingFeeReceiver, stakingReserved);
        }

        console.log('reward amount is');
        console.log(rewardAmount);

        for(uint i = 0; i < account.length; i++) {

            require(weight[i] <= 100, "Invalid weight parameters");
            require(account[i] != msg.sender, "Owner cannot claim reward itself");
            uint256 userRewarded = rewardAmount / 100 * weight[i];

            if(isNativeToken(asset)) {
                payable(account[i]).transfer(userRewarded);
            } else {
                ERC20(asset).transfer(account[i], userRewarded);
            }

            distributedReward += userRewarded;

        }

        require(rewardAmount == distributedReward, "Rewards did not all distributed");
        emit questionClosed(id, account, weight);
       
    }

    function closeExpiredQuestion(string[] memory ids) external onlyOwner {
        address[] memory tempAddress = new address[](1);
        tempAddress[0] = stakingFeeReceiver;
        uint256[] memory tempWeight = new uint256[](1);
        tempWeight[0] = 100;
        for(uint i = 0; i < ids.length; i++) {
            closeQuestion(ids[i], tempAddress, tempWeight);
        }
    }

    function receive() external payable {}

    fallback() external payable {}

    event parameterAdjusted(string name, uint256 amount);
    event questionCreated(string id, uint256 amount);
    event questionClosed(string id, address[] account, uint256[] weight);
    event questionExpired(string id);
    event SetAsset(address indexed asset, uint256 amount);
    event RemoveAsset(address indexed asset);

}