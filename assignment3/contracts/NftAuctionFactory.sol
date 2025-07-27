// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/UUPSUpgradeable.sol";
import "./NftAuction.sol";

contract NftAuctionFactory is Initializable, UUPSUpgradeable {

    mapping(string => address) public auctionMap; // 拍卖ID → 合约地址
    address admin;

    event AuctionCreated(string auctionId, address auctionAddr);

    function initialize() public initializer {
        admin = msg.sender;
    }

    // 创建新拍卖（核心工厂方法）
    function createAuction(
        string calldata  _auctionId,
        address _nftAddress,
        uint256 _tokenId,
        uint256 _startTime,
        uint256 _duration,
        uint256 _startPrice
    ) external {
        // 防止重复创建
        require(auctionMap[_auctionId] == address(0), "Auction exists");
        
        NftAuction newAuction = new NftAuction(
            msg.sender,
            _nftAddress,
            _tokenId,
            _startTime,
            _duration,
            _startPrice,
            admin
        );
        address auctionAddress = address(newAuction);
        // 转移NFT到合约中
        IERC721(_nftAddress).safeTransferFrom(msg.sender, auctionAddress, _tokenId);

        auctionMap[_auctionId] = auctionAddress;
        emit AuctionCreated(_auctionId, auctionAddress);
    }

    function getAuctionAddress(string calldata _auctionId) external view returns (address) {
        return auctionMap[_auctionId];
    }

    function _authorizeUpgrade(address) internal view override {
        // 只有管理员可以升级合约
        require(msg.sender == admin, "Only admin can upgrade");
    }
}