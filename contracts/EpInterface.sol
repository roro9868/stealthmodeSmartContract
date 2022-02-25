// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

interface ERC20 {
    function mint(address account, uint256 amount) external;
    function burnFrom(address account, uint256 amount) external;
    function balanceOf(address account) external view returns (uint256);
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);
    function approve(address spender, uint256 allowance) external;
    function increaseAllowance(address spender, uint256 addedValue) external;
    function decreaseAllowance(address spender, uint256 subtractedValue) external;
}