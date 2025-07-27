// SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity ^0.8;

import "@openzeppelin/contracts/interfaces/IERC721Receiver.sol";
import "@openzeppelin/contracts/token/ERC721/IERC721.sol";
import "hardhat/console.sol";

contract NftAuction is IERC721Receiver {
    // 卖家
    address public seller;
    // 拍卖持续时间
    uint256 public duration;
    // 起始价格
    uint256 public startPrice;
    // 开始时间
    uint256 public startTime;
    // NFT合约地址
    address public nftAddress;
    // NFT ID
    uint256 public tokenId;
    // 是否结束
    bool public ended;
    // 最高出价者
    address public highestBidder;
    // 最高价格
    uint256 public highestBid;
    // 管理员地址
    address public admin;
    // 参与竞价的资产类型 0x 地址表示eth，其他地址表示erc20
    // 0x0000000000000000000000000000000000000000 表示eth
    // address tokenAddress;

    constructor(
        address _seller,
        address _nftAddress,
        uint256 _tokenId,
        uint256 _startTime,
        uint256 _duration,
        uint256 _startPrice,
        address _admin
    ) {
        // 检查参数
        require(_duration > 0, "Duration must be greater than 0s");
        require(_startPrice > 0, "Start price must be greater than 0");
        require(
            (_startTime + _duration) > block.timestamp,
            "Invalid startTime and duration"
        );

        admin = _admin;
        seller = _seller;
        duration = _duration;
        startPrice = _startPrice;
        startTime = _startTime;
        nftAddress = _nftAddress;
        tokenId = _tokenId;
    }

    function placeBid() external payable {
        // 判断当前拍卖是否结束
        require(
            !ended,
            "Auction has ended"
        );
        // 判断出价是否大于当前最高出价
        require(
            msg.value >= startPrice && msg.value > highestBid,
            "Bid must be higher than the current highest bid"
        );

        // 退还前最高价
        if (highestBid > 0) {
            payable(highestBidder).transfer(highestBid);
        }
        highestBid = msg.value;
        highestBidder = msg.sender;
    }

    // 结束拍卖
    function endAuction() external {
        require(msg.sender == seller, "Only seller can end auction");
        // 判断当前拍卖是否结束
        require(
            (startTime + duration) <= block.timestamp,
            "Auction has not ended"
        );
        require(
            !ended,
            "Auction has already ended"
        );
        ended = true;
        if (highestBidder == address(0)) {
            // 没人买, 退回卖家
            IERC721(nftAddress).safeTransferFrom(address(this), seller, tokenId);
        } else {
            // 转移NFT给买家
            IERC721(nftAddress).safeTransferFrom(address(this), highestBidder, tokenId);
            // 转移10%手续费给管理员
            uint256 tip = highestBid / 10;
            payable(admin).transfer(tip);
            // 转移剩余资金到卖家
            payable(seller).transfer(highestBid - tip);
        }
    }

    function onERC721Received(
        address operator,
        address from,
        uint256 tokenId,
        bytes calldata data
    ) external override pure returns (bytes4) {
        return IERC721Receiver.onERC721Received.selector;
    }
}