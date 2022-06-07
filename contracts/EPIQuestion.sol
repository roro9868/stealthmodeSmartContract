// SPDX-License-Identifier: MIT

pragma solidity ^0.8.7;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/security/Pausable.sol";
import "./EPIInterface.sol";

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
        address creator;
        address asset;
        bool notClosed;
        uint256 startTimestamp;
        uint256 expireAfterSecs;
        uint256 delegateAmount;
        string tag;
    }

    mapping(string => Question) public questionsInfo;
    mapping(address => uint256) public assetMinPrice;
    mapping(address => uint256) public communityFeeMap;

    uint256 public communityPercent;
    uint256 public stakingPercent;
    address public stakingFeeReceiver;

    constructor( 
        address _stakingFeeReceiver,
        uint256 _communityPercent,
        uint256 _stakingPercent
    ) {
        stakingFeeReceiver = _stakingFeeReceiver;
        communityPercent = _communityPercent;
        stakingPercent = _stakingPercent;
    }

    function pause() external onlyOwner {
        _pause();
    }

    function unpause() external onlyOwner {
        _unpause();
    }

    function setstakingFeeReceiver(address _receiverAddress) external onlyOwner {
        stakingFeeReceiver = _receiverAddress;
    }

    function setAsset(address _asset, uint256 _amount) external onlyOwner {
        assetMinPrice[_asset] = _amount;
        emit SetAsset(_asset, _amount);
    }

    function removeAsset(address _asset) external onlyOwner {
        delete assetMinPrice[_asset];
        emit RemoveAsset(_asset);
    }

    function isSupportedAsset(address _asset) public view returns (bool) {
        return assetMinPrice[_asset] > 0;
    }

    function adjustCommunityPercent(uint256 _communityPercent) external onlyOwner {
        communityPercent = _communityPercent;
        emit parameterAdjusted("communityPercent", communityPercent);
    }

    function adjustStakingPercent(uint256 _stakingPercent) external onlyOwner {
        stakingPercent = _stakingPercent;
        emit parameterAdjusted("stakingPercent", stakingPercent);
    }

    function isNativeToken(address _asset) internal pure returns (bool) {
        return _asset == address(0);
    }

    function recoverTokens(address[] memory _assets) external onlyOwner {
        for(uint i = 0; i < _assets.length; i++) {
            address asset = _assets[i];
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

    function withdrawCommunityFee(address[] memory _assets) external onlyOwner {
        for(uint i = 0; i < _assets.length; i++) {
            address asset = _assets[i];
            require(isSupportedAsset(asset), 'Asset not supported');
            if(isNativeToken(asset)) {
                payable(msg.sender).transfer(communityFeeMap[asset]);
            } else {
                ERC20(asset).transfer(msg.sender, communityFeeMap[asset]);
            }
            communityFeeMap[asset] = 0;
        }
    }

    function _createQuestion(address _asset, string memory _id, uint256 _amount, uint256 _expireAfterSecs, string memory _tag) internal {
        questionsInfo[_id].creator = msg.sender;
        questionsInfo[_id].notClosed = true;
        questionsInfo[_id].delegateAmount = _amount;
        questionsInfo[_id].startTimestamp = block.timestamp;
        questionsInfo[_id].expireAfterSecs = _expireAfterSecs;
        questionsInfo[_id].asset = _asset;
        questionsInfo[_id].tag = _tag;
        emit questionCreated(questionsInfo[_id]);
    }


    function postQuestion(address _asset, string memory _id, uint256 _amount, uint256 expireAfterSecs, string memory _tag) payable external whenNotPaused {

        require(isSupportedAsset(_asset), 'Invalid asset');
        require(questionsInfo[_id].creator == address(0), "duplicate question ID");
        uint256 minPrice = assetMinPrice[_asset];

        if(isNativeToken(_asset)) {
            require(address(msg.sender).balance >= minPrice,  "Insufficient amount to delegate");
            require(msg.value == _amount, 'Delegate amount should equal to msg.value');
            require(msg.value >= minPrice, "Minimum question fee required");
        } else {
            require(msg.value == 0, 'Should not transfer native token when ERC20 token is selected');
            require(ERC20(_asset).balanceOf(msg.sender) >= assetMinPrice[_asset], "Insufficient amount to delegate");
            require(_amount >= assetMinPrice[_asset], "Minimum question fee required");
            ERC20(_asset).transferFrom(msg.sender, address(this), _amount);
        }

        _createQuestion(_asset, _id, _amount, expireAfterSecs, _tag);

    }

    function isQuestionExpired(string memory _id) public view returns (bool) {
        return questionsInfo[_id].startTimestamp + questionsInfo[_id].expireAfterSecs <= block.timestamp;
    }

    function closeQuestion(string memory _id, address[] memory _accounts, uint256[] memory _weights) whenNotPaused public {

        // require(isQuestionExpired(_id), 'Question not expired'); disabling this for testnet. 
        require(questionsInfo[_id].creator == msg.sender || msg.sender == owner(), 'msg.sender not authorized to close this question');
        require(questionsInfo[_id].notClosed, "Question closed");
        address asset = questionsInfo[_id].asset;

        questionsInfo[_id].notClosed = false;
        uint256 delegateAmount = questionsInfo[_id].delegateAmount;
        uint256 reservedFee = delegateAmount / 100 * communityPercent;
        communityFeeMap[asset] += reservedFee;
    
        uint256 stakingReserved = delegateAmount / 100 * stakingPercent;
        uint256 rewardAmount = delegateAmount - reservedFee - stakingReserved;
        uint256 distributedReward = 0;

        if(isNativeToken(asset)) {
            payable(stakingFeeReceiver).transfer(stakingReserved);
        } else {
            ERC20(asset).transfer(stakingFeeReceiver, stakingReserved);
        }

        for(uint i = 0; i < _accounts.length; i++) {

            require(_weights[i] <= 100, "Invalid weight parameters");
            require(_accounts[i] != msg.sender, "Question creator cannot claim reward itself");
            uint256 userRewarded = rewardAmount / 100 * _weights[i];

            if(isNativeToken(asset)) {
                payable(_accounts[i]).transfer(userRewarded);
            } else {
                ERC20(asset).transfer(_accounts[i], userRewarded);
            }

            distributedReward += userRewarded;

        }

        require(rewardAmount == distributedReward, "Rewards did not all distributed");
        emit questionClosed(_id, reservedFee, stakingReserved, _accounts, _weights);
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

    receive() external payable {}

    fallback() external payable {}

    event parameterAdjusted(string name, uint256 amount);
    event questionCreated(Question question);
    event questionClosed(string id, uint256 reservedFee, uint256 stakingReserved, address[] account, uint256[] weight);
    event SetAsset(address indexed asset, uint256 amount);
    event RemoveAsset(address indexed asset);

}