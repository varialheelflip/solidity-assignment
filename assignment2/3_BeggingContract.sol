// SPDX-License-Identifier: MIT
pragma solidity ^0.8;

contract BeggingContract {

    mapping(address => uint256) beggingCounts;
    address[3] public rank;
    uint256 public startTime = 0;
    uint256 public endTime = 4087555199;

    address immutable owner;
    constructor() {
        owner = msg.sender;
    }

    event Donate(address indexed sender, uint256 amount);

    modifier onlyOwner {
        require(msg.sender == owner, "only owner can call");
        _;
    }

    modifier onlyTimeInterval {
        require(block.timestamp >= startTime, "not start");
        require(block.timestamp <= endTime, "already end");
        _;
    }

    function withdraw() external onlyOwner {
        require(address(this).balance > 0, "no money to withdraw");
        payable(owner).transfer(address(this).balance);
    }

    function getDonation(address _addr) external view returns (uint256) {
        return beggingCounts[_addr];
    }

    receive() external payable onlyTimeInterval {
        donateLogic();
    }

    function donate() external payable onlyTimeInterval {
        require(msg.value > 0, "amount must be greater than zero");
        donateLogic();
    }

    function setTime(uint256 newStartTime, uint256 newEndTime) external onlyOwner {
        require(newStartTime < newEndTime, "startTime must earlier than endTime");
        startTime = newStartTime;
        endTime = newEndTime;
    }

    function donateLogic() private {
        beggingCounts[msg.sender] += msg.value;
        emit Donate(msg.sender, msg.value);
        updateRank(msg.sender);
    }

    // 排序有点费gas, 而且没有原生api支持, 后续可考虑由客户端处理
    function updateRank(address addr) private {
        uint256 currentMinDonate = beggingCounts[rank[2]];
        
        // 地址在排行榜中的情况
        if (isInRank(addr)) {
            sortRank();
        } else if (beggingCounts[addr] > currentMinDonate || currentMinDonate == 0) {
            // 地址未在榜中但分数超过第三名, 或者前三名有空缺的情况
            rank[2] = addr;
            sortRank();
        }
    }

    function isInRank(address addr) private view returns (bool) {
        for (uint i = 0; i < 3; i++) {
            if (rank[i] == addr) {
                return true;
            }
        }
        return false;
    }

    // 冒泡排序
    function sortRank() private {
        for (uint i = 0; i < 3; i++) {
            for (uint j = i + 1; j < 3; j++) {
                address a = rank[i];
                address b = rank[j];
                
                if ((beggingCounts[a] < beggingCounts[b])) {
                    (rank[i], rank[j]) = (b, a);
                }
            }
        }
    }

}