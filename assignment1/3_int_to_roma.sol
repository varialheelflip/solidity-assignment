// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/utils/Strings.sol";

contract Solution {
    mapping (bytes1 => string) thousandMap;
    mapping (bytes1 => string) hundredMap;
    mapping (bytes1 => string) tenMap;
    mapping (bytes1 => string) oneMap;

    function test() external  {
        assert(keccak256(abi.encodePacked(intToRoma(3749)))
        == keccak256(abi.encodePacked("MMMDCCXLIX")));

        assert(keccak256(abi.encodePacked(intToRoma(58)))
        == keccak256(abi.encodePacked("LVIII")));

        assert(keccak256(abi.encodePacked(intToRoma(1994)))
        == keccak256(abi.encodePacked("MCMXCIV")));

        assert(keccak256(abi.encodePacked(intToRoma(3749)))
        == keccak256(abi.encodePacked("MMMDCCXLIX")));

        assert(keccak256(abi.encodePacked(intToRoma(1)))
        == keccak256(abi.encodePacked("I")));

        assert(keccak256(abi.encodePacked(intToRoma(3)))
        == keccak256(abi.encodePacked("III")));

        assert(keccak256(abi.encodePacked(intToRoma(4)))
        == keccak256(abi.encodePacked("IV")));

        assert(keccak256(abi.encodePacked(intToRoma(10)))
        == keccak256(abi.encodePacked("X")));

        assert(keccak256(abi.encodePacked(intToRoma(49)))
        == keccak256(abi.encodePacked("XLIX")));

        assert(keccak256(abi.encodePacked(intToRoma(388)))
        == keccak256(abi.encodePacked("CCCLXXXVIII")));

        assert(keccak256(abi.encodePacked(intToRoma(1994)))
        == keccak256(abi.encodePacked("MCMXCIV")));

        assert(keccak256(abi.encodePacked(intToRoma(3999)))
        == keccak256(abi.encodePacked("MMMCMXCIX")));

        assert(keccak256(abi.encodePacked(intToRoma(101)))
        == keccak256(abi.encodePacked("CI")));

        assert(keccak256(abi.encodePacked(intToRoma(444)))
        == keccak256(abi.encodePacked("CDXLIV")));
    }

    function intToRoma(uint input) public returns (string memory){
        require(input > 0, "invalid input");
        initMap();
        bytes memory bytesArr = bytes(Strings.toString(input));
        if (bytesArr.length == 4) {
            return string.concat(thousandMap[bytesArr[0]], hundredMap[bytesArr[1]], tenMap[bytesArr[2]], oneMap[bytesArr[3]]);
        }
        if (bytesArr.length == 3) {
            return string.concat(hundredMap[bytesArr[0]], tenMap[bytesArr[1]], oneMap[bytesArr[2]]);
        }
        if (bytesArr.length == 2) {
            return string.concat(tenMap[bytesArr[0]], oneMap[bytesArr[1]]);
        }
        return oneMap[bytesArr[0]];
    }

    function initMap() private {
        // 初始化转换值
        thousandMap["1"] = "M";
        thousandMap["2"] = "MM";
        thousandMap["3"] = "MMM";

        hundredMap["0"] = "";
        hundredMap["1"] = "C";
        hundredMap["2"] = "CC";
        hundredMap["3"] = "CCC";
        hundredMap["4"] = "CD";
        hundredMap["5"] = "D";
        hundredMap["6"] = "DC";
        hundredMap["7"] = "DCC";
        hundredMap["8"] = "DCCC";
        hundredMap["9"] = "CM";

        tenMap["0"] = "";
        tenMap["1"] = "X";
        tenMap["2"] = "XX";
        tenMap["3"] = "XXX";
        tenMap["4"] = "XL";
        tenMap["5"] = "L";
        tenMap["6"] = "LX";
        tenMap["7"] = "LXX";
        tenMap["8"] = "LXXX";
        tenMap["9"] = "XC";

        oneMap["0"] = "";
        oneMap["1"] = "I";
        oneMap["2"] = "II";
        oneMap["3"] = "III";
        oneMap["4"] = "IV";
        oneMap["5"] = "V";
        oneMap["6"] = "VI";
        oneMap["7"] = "VII";
        oneMap["8"] = "VIII";
        oneMap["9"] = "IX";
    }
}