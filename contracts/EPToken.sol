// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC20/extensions/ERC20Burnable.sol";

contract EPToken is ERC20Burnable, Ownable {

    mapping(address => bool) internal whiteList;

    constructor(uint256 initialSupply) ERC20("RICH", "RICH") {
        whiteList[msg.sender] = true;
        _mint(msg.sender, initialSupply);
    }

    function checkWhiteList(address account) public view returns (bool) {
        return whiteList[account];
    }

    function setWhiteList(address account, bool whiteListState) onlyOwner external {
        whiteList[account] = whiteListState;
        emit WhiteList(account, whiteListState);
    }

    function mint(address account, uint256 amount) public {
        require(whiteList[msg.sender], "Account not whitelist to mint token");
        _mint(account, amount);
    }

    event WhiteList(address account, bool state);

}
