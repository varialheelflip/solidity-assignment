// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract Solution {
    function mergeSortedArray(uint[] calldata arr1, uint[] calldata arr2) external pure returns (uint[] memory) {
        // 处理边界条件
        if (arr1.length == 0) {
            return arr2;
        }
        if (arr2.length == 0) {
            return arr1;
        }
        uint[] memory result = new uint[](arr1.length + arr2.length);
        uint resultStart;
        uint a1Start;
        uint a2Start;
        while (a1Start <= arr1.length -  1 && a2Start <= arr2.length -  1) {
            if (arr1[a1Start] <= arr2[a2Start]) {
                result[resultStart++] = arr1[a1Start++];
            } else {
                result[resultStart++] = arr2[a2Start++];
            }
        }
        while (a1Start <= arr1.length -  1) {
            result[resultStart++] = arr1[a1Start++]; 
        }
        while (a2Start <= arr2.length -  1) {
            result[resultStart++] = arr2[a2Start++]; 
        }

        return result;
    }
}