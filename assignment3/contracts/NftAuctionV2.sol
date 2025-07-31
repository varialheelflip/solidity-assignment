// SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity ^0.8;

import "@openzeppelin/contracts/interfaces/IERC721Receiver.sol";
import "@openzeppelin/contracts/token/ERC721/IERC721.sol";
import {AggregatorV3Interface} from "@chainlink/contracts/src/v0.8/shared/interfaces/AggregatorV3Interface.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "hardhat/console.sol";

contract NftAuctionV2 is IERC721Receiver {
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
    // 最高出价的ERC20货币地址, 0地址则为ETH
    address public highestBidErc20Address;
    // 货币对应的喂价器
    mapping(address => AggregatorV3Interface) public priceFeeds;

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

    function setPriceFeed(
        address _tokenAddress,
        address _priceFeed
    ) public {
        require(msg.sender == admin, "Only admin can set priceFeed");
        priceFeeds[_tokenAddress] = AggregatorV3Interface(_priceFeed);
    }

    function getChainlinkDataFeedLatestAnswer(
        address tokenAddress
    ) public view returns (uint256, uint8) {
        AggregatorV3Interface priceFeed = priceFeeds[tokenAddress];
        (
            /* uint80 roundId */,
            int256 answer,
            /*uint256 startedAt*/,
            /*uint256 updatedAt*/,
            /*uint80 answeredInRound*/
        ) = priceFeed.latestRoundData();
        return (uint256(answer), priceFeed.decimals());
    }

    // 使用ETH来竞价
    function placeBid() external payable {
        placeBid(address(0), msg.value);
    }

    // 使用ERC20来竞价
    function placeBid(address _ercAddress, uint256 _amount) public payable {
        // 判断当前拍卖是否结束
        require(
            !ended,
            "Auction has ended"
        );
        // 判断出价是否大于当前最高出价
        (uint256 ercAnswer, uint8 ercDecimals) = getChainlinkDataFeedLatestAnswer(_ercAddress);
        (uint256 highestBidAnswer, uint8 highestBidDecimals) = getChainlinkDataFeedLatestAnswer(highestBidErc20Address);
        uint256 startPriceScale = startPrice * 10**18;
        uint256 ercScale;
        if (_ercAddress == address(0)) {
            // wei需要转换到ETH
            ercScale = _amount * ercAnswer * (10**(18-ercDecimals))/(10**18);
        } else {
            ercScale = _amount * ercAnswer * (10**(18-ercDecimals));
        }
        uint256 highestBidScale = highestBid * highestBidAnswer * (10**(18-highestBidDecimals));
        require(
            ercScale >= startPriceScale && ercScale > highestBidScale,
            "Bid must be higher than the current highest bid"
        );
        // 转移代币到合约
        if (_ercAddress == address(0)) {
            // 转移ETH
            require(msg.value == _amount, "not enough money");
        } else{
            // 转移普通ERC20
            IERC20(_ercAddress).transferFrom(msg.sender, address(this), _amount);
        }
        // 退还前最高价
        if (highestBid > 0) {
            if (_ercAddress == address(0)) {
                // 转移ETH
                payable(highestBidder).transfer(highestBid);
            } else{
                // 转移普通ERC20
                IERC20(highestBidErc20Address).transferFrom(address(this), highestBidder, highestBid);
            }
        }
        highestBid = _amount;
        highestBidder = msg.sender;
        highestBidErc20Address = _ercAddress;
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
            return;
        }
        // 转移NFT给买家
        IERC721(nftAddress).safeTransferFrom(address(this), highestBidder, tokenId);
        // 转移10%手续费给管理员
        // 转移剩余资金到卖家
        uint256 tip = highestBid / 10;
        if (highestBidErc20Address == address(0)) {
            payable(admin).transfer(tip);
            payable(seller).transfer(highestBid - tip);
        } else {
            IERC20(highestBidErc20Address).transfer(admin, tip);
            IERC20(highestBidErc20Address).transfer(seller, highestBid - tip);
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