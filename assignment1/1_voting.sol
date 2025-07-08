// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract Voting {
    // 版本号, 用于重置
    uint private version = 0;
    // 存储候选人票数
    mapping( uint => mapping(address => uint) ) private votes;
    // 存储是否投票了
    mapping( uint => mapping(address => bool) ) private isVoted;

    function vote(address to) external {
        require(!(isVoted[version][msg.sender]), "already voted");
        isVoted[version][msg.sender] = true;
        votes[version][to]++;
    }

    function getVotes(address to) external view returns (uint) {
        return votes[version][to];
    }

    function resetVotes() external {
        version++;
    }
}