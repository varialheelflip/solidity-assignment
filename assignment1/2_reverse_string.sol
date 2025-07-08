// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract Solution {
    function reverseString(string calldata input) external pure returns (string memory output){
        bytes memory byteArr = bytes(input);
        if (byteArr.length == 0) {
            return "";
        }
        uint head = 0;
        uint tail = byteArr.length - 1;
        while (head < tail){
            bytes1 tempByte = byteArr[tail];
            byteArr[tail] = byteArr[head];
            byteArr[head] = tempByte;
            head++;
            tail--;
        }
        return string(byteArr);
    }
}