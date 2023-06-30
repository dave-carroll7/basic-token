// SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.4.22 <0.9.0;

import "./interfaces/IERC20.sol";

contract ERC20 is IERC20 {

    string private _name;
    string private _symbol;

    // maps token holder to balance
    mapping(address => uint256) private _balances;

    // maps token holder to spender to allowance
    mapping(address => mapping(address => uint256)) private _approvals;


    constructor(string memory name_, string memory symbol_) {
        _name = name_;
        _symbol = symbol_;
    }

    function totalSupply() external view returns (uint256) {

    }
    
    function balanceOf(address account) external view returns (uint256) {
        return _balances[account];
    }

    
    function transfer(address to, uint256 amount) external returns (bool) {
        require(_balances[msg.sender] >= amount, "Insufficient funds");
        _balances[msg.sender] -= amount;
        _balances[to] += amount;
        emit Transfer(msg.sender, to, amount);
        return true;
    }

    
    function allowance(address owner, address spender) external view returns (uint256) {
        return _approvals[owner][spender];
    }

    
    function approve(address spender, uint256 amount) external returns (bool) {
        require(msg.sender != spender, "Can't approve owner as spender");
        _approvals[msg.sender][spender] += amount;
        emit Approval(msg.sender, spender, amount);
        return true;
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
