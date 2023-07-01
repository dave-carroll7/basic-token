// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

import "./interfaces/IERC20.sol";

/**
 * @dev Implementation of https://eips.ethereum.org/EIPS/eip-20 Token Standard.
 */
contract ERC20 is IERC20 {

    // token name
    string private _name;
    
    // token symbol
    string private _symbol;

    // maps token holder to balance
    mapping(address => uint256) private _balances;

    // maps token holder to approved spender to allowance
    mapping(address => mapping(address => uint256)) private _allowances;

    // total token supply
    uint256 _totalSupply;

    /**
     * @dev Initalizes contract, sets `_name` and `_symbol` to parameters, sets `_totalSupply` to zero.
     */
    constructor(string memory name_, string memory symbol_) {
        _name = name_;
        _symbol = symbol_;
        _totalSupply = 0;
    }

    /**
     * @dev See {IERC20-totalSupply}.
     */
    function totalSupply() external view returns (uint256) {
        return _totalSupply;
    }
    
    /**
     * @dev See {IERC20-balanceOf}.
     */
    function balanceOf(address account) external view returns (uint256) {
        return _balances[account];
    }

    /**
     * @dev See {IERC20-transfer}.
     */
    function transfer(address to, uint256 amount) external returns (bool) {
        require(_balances[msg.sender] >= amount, "Insufficient funds");
        require(to != address(0), "Transfer to zero address");
        _balances[msg.sender] -= amount;
        _balances[to] += amount;
        emit Transfer(msg.sender, to, amount);
        return true;
    }

    /**
     * @dev See {IERC20-allowance}.
     */
    function allowance(address owner, address spender) external view returns (uint256) {
        return _allowances[owner][spender];
    }

    /**
     * @dev See {IERC20-approve}.
     */
    function approve(address spender, uint256 amount) external returns (bool) {
        require(spender != address(0), "Approval of zero address");
        require(msg.sender != spender, "Approval of owner as spender");
        _allowances[msg.sender][spender] = amount;
        emit Approval(msg.sender, spender, amount);
        return true;
    }

    /**
     * @dev See {IERC20-transferFrom}.
     */
    function transferFrom(
        address from,
        address to,
        uint256 amount
    ) external returns (bool) {
        require(_allowances[from][msg.sender] >= amount, "Insufficient allowance");
        require(_balances[from] >= amount, "Insufficient funds");
        require(to != address(0), "Transfer to zero address");
        _allowances[from][msg.sender] -= amount;
        _balances[from] -= amount;
        _balances[to] += amount;
        emit Transfer(from, to, amount);
        return true;
    }

    /**
     * @dev See {IERC20-name}.
     */
    function name() public view returns (string memory) {
        return _name;
    }

    /**
     * @dev See {IERC20-symbol}.
     */
    function symbol() public view returns (string memory) {
        return _symbol;
    }

    /**
     * @dev Mints `amount` tokens and transfers them to `to`.
     */
    function _mint(address to, uint256 amount) internal virtual returns (bool) {
        require(to != address(0), "Transfer to zero address");
        _totalSupply += amount;
        _balances[to] += amount;
        emit Transfer(address(0), to, amount);
        return true;
    }
}
