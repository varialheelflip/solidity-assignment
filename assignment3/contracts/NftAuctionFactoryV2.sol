// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./NftAuctionFactory.sol";
import "./NftAuctionV2.sol";

contract NftAuctionFactoryV2 is NftAuctionFactory {

    // 创建新拍卖（核心工厂方法）
    function createAuctionV2(
        string calldata  _auctionId,
        address _nftAddress,
        uint256 _tokenId,
        uint256 _startTime,
        uint256 _duration,
        uint256 _startPrice
    ) external {
        // 防止重复创建
        require(auctionMap[_auctionId] == address(0), "Auction exists");
        
        NftAuctionV2 newAuction = new NftAuctionV2(
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
}