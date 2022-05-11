// SPDX-License-Identifier: MIT

pragma solidity 0.8.7;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract TestToken is ERC20 {
   constructor() ERC20 ("TEST", "TEST"){
      _mint(msg.sender, 100000 ether);
   }
}