// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract Solution {
    mapping (string => uint) convertMap;
    function romaToInt(string calldata input) external returns (uint){
        initMap();
        bytes memory byteArr = bytes(input);
        require(byteArr.length > 0, "the string can not be empty");
        if (byteArr.length == 1) {
            return convertMap[input];
        }
        uint start = 0;
        uint result;
        while (start <= byteArr.length - 1) {
            // 遍历到最后一位了
            if (start == byteArr.length - 1) {
                bytes memory tempBytes1 = new bytes(1);
                tempBytes1[0] = byteArr[start];
                result += convertMap[string(tempBytes1)];
                break;
            }
            // 两两配对
            bytes memory tempBytes = new bytes(2);
            tempBytes[0] = byteArr[start];
            tempBytes[1] = byteArr[start + 1];
            if (convertMap[string(tempBytes)] > 0) {
                result += convertMap[string(tempBytes)] ;
                start += 2;
            }else {
                bytes memory singleByte = new bytes(1);
                singleByte[0] = byteArr[start];
                result += convertMap[string(singleByte)];
                start += 1;
            }
        }
        return result;
    }

    function initMap() private {
        // 初始化转换值
        convertMap["I"] = 1;
        convertMap["V"] = 5;
        convertMap["X"] = 10;
        convertMap["L"] = 50;
        convertMap["C"] = 100;
        convertMap["D"] = 500;
        convertMap["M"] = 1000;
        convertMap["IV"] =  4;
        convertMap["IX"] = 9; 
        convertMap["XL"]= 40;
        convertMap["XC"]= 90;
        convertMap["CD"]=  400;
        convertMap["CM"]  =  900;
    }
}