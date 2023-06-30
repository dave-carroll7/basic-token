// SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.4.22 <0.9.0;

import "./interfaces/IERC20.sol";

contract ERC20 is IERC20 {

    mapping(address => uint256) public balances;

    
    string private _name;
    string private _symbol;

    constructor(string memory name_, string memory symbol_) {
        _name = name_;
        _symbol = symbol_;
    }

    function totalSupply() external view returns (uint256) {

    }
    
    function balanceOf(address account) external view returns (uint256) {
        return balances[account];
    }

    
    function transfer(address to, uint256 amount) external returns (bool) {
        
    }

    
    function allowance(address owner, address spender) external view returns (uint256) {

    }

    
    function approve(address spender, uint256 amount) external returns (bool) {

    }

    
    function transferFrom(
        address from,
        address to,
        uint256 amount
    ) external returns (bool) {

    }

    function name() public view returns (string memory) {
        return _name;
    }

    function symbol() public view returns (string memory) {
        return _symbol;
    }

}
