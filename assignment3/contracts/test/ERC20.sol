// SPDX-License-Identifier: MIT
pragma solidity ^0.8;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

contract ERC20 is IERC20 {

    mapping(address account => uint256) private _balances;

    mapping(address spender => mapping(address owner => uint256))  _allowances;

    address immutable owner;
    constructor() {
        owner = msg.sender;
    }
    modifier onlyOwner {
        require(msg.sender == owner, "only owner can call");
        _;
    }

    function balanceOf(address account) external view returns (uint256) {
        return _balances[account];
    }

    function transfer(address to, uint256 value) external returns (bool) {
        // 校验
        require(value > 0, "value must bigger than 0");
        require(_balances[msg.sender] >= value, "not enough balance");
        _balances[msg.sender] -= value;
        _balances[to] += value;
        emit Transfer(msg.sender, to, value);
        return true;
    }

    function approve(address spender, uint256 value) external returns (bool) {
        _allowances[spender][msg.sender] = value;
        emit Approval(msg.sender, spender, value);
        return true;
    }

    function transferFrom(address from, address to, uint256 value) external returns (bool) {
        // 校验
        require(value > 0, "value must bigger than 0");
        require(value <= _allowances[msg.sender][from], "exceeds approved amount");
        require(_balances[from] >= value, "not enough balance");
        _allowances[msg.sender][from] -= value;
        _balances[from] -= value;
        _balances[to] += value;
        emit Transfer(from, to, value);
        return true;
    }

    function mint(address account, uint256 value) external onlyOwner {
        _balances[account] += value;
    }

    function allowance(address owner, address spender) external view returns (uint256) {
        return _allowances[spender][owner];
    }

    function totalSupply() external view returns (uint256) {
        return 0;
    }

}