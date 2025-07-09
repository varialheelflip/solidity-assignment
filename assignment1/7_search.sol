// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract Solution {
    function search(int[] calldata nums, int target) external pure returns (int) {
        if (nums.length == 0) {
            return -1;
        }
        if (nums.length == 1) {
            return target == nums[0] ? int(0) : int(-1);
        }
        uint left = 0;
        uint right = nums.length - 1;
        while (left <= right) {
            uint mid = (right + left) / 2;
            if (nums[mid] == target) return int(mid);
            else if (nums[mid] < target) left = mid + 1;
            else right = mid - 1;
        }
        return -1;
    }
}