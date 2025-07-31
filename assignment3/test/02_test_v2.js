const { ethers, deployments, getNamedAccounts } = require("hardhat")
const { expect } = require("chai")


describe("Test auction v2", async function () {
    it("Should be ok with eth", async function () {
        // 测试用eth拍卖
        await ethPay();
    });

    it("Should be ok with erc20", async function () {
        // 测试用erc20拍卖
        await erc20Pay();
    });
})

async function ethPay() {
    const [deployer, seller, buyer] = await ethers.getSigners();
    await deployments.fixture(["depolyNftAuctionFactory", "upgradeNftAuction"]);

    const nftAuctionProxy = await deployments.get("NftAuctionProxyV2");
    const nftAuctionFactory = await ethers.getContractAt(
        "NftAuctionFactoryV2",
        nftAuctionProxy.address
    );

    // 1. 部署 ERC721 合约
    const TestERC721 = await ethers.getContractFactory("NFT");
    const testERC721 = await TestERC721.connect(deployer).deploy();
    await testERC721.waitForDeployment();
    const testERC721Address = await testERC721.getAddress();
    console.log("testERC721Address::", testERC721Address);
    // mint 10个 NFT
    for (let i = 0; i < 10; i++) {
        await testERC721.mintNFT(seller.address, i + '');
    }

    const tokenId = 1;   
    // 授权NFT给代理合约
    await testERC721.connect(seller).approve(nftAuctionProxy.address, tokenId);

    const autionId = "first aution";
    await nftAuctionFactory.connect(seller).createAuctionV2(
        autionId,
        testERC721Address,
        tokenId,
        Math.floor(Date.now() / 1000),
        20,
        14000000
    );

    const auctionAddress = await nftAuctionFactory.getAuctionAddress(autionId);
    console.log("创建拍卖成功：：", auctionAddress);

    // 管理员设置chainlink喂价
    const AggregatorV3 = await ethers.getContractFactory("AggregatorV3");
    // 1ETH = 14000RMB, 8位精度
    const aggregatorV3 = await AggregatorV3.connect(deployer).deploy(14000 * (10**8));
    await aggregatorV3.waitForDeployment();
    const aggregatorV3Address = await aggregatorV3.getAddress();
    console.log("aggregatorV3Address::", aggregatorV3Address);
    const nftAuctionV2 = await ethers.getContractAt("NftAuctionV2", auctionAddress);
    nftAuctionV2.connect(deployer).setPriceFeed(ethers.ZeroAddress, aggregatorV3Address);

    // 3. 购买者参与拍卖
    // 竞价不够, 报错
    await expect(
      nftAuctionV2.connect(buyer).placeBid({ value: ethers.parseEther("1") })
    ).to.be.revertedWith("Bid must be higher than the current highest bid");
    // 成功竞价
    await nftAuctionV2.connect(buyer).placeBid({ value: ethers.parseEther("2000") })

    // 4. 结束拍卖
    // 等待
    await new Promise((resolve) => setTimeout(resolve, 25 * 1000));
    await nftAuctionV2.connect(seller).endAuction();
    const GAS_TOLERANCE = ethers.parseUnits("0.1", "ether"); // 0.1 ETH 容忍度
    const deployerBalance = await ethers.provider.getBalance(deployer);
    const buyerBalance = await ethers.provider.getBalance(buyer);
    const sellerBalance = await ethers.provider.getBalance(seller);
    console.log("deployer: ", ethers.formatEther(String(deployerBalance)));
    console.log("buyer: ", ethers.formatEther(String(buyerBalance)));
    console.log("seller: ", ethers.formatEther(String(sellerBalance)));
    // deployer得到200手续费
    expect(deployerBalance).to.be.closeTo(ethers.parseEther("10200"), GAS_TOLERANCE);
    // buyer失去2000
    expect(buyerBalance).to.be.closeTo(ethers.parseEther("8000"), GAS_TOLERANCE);
    // seller得到1800
    expect(sellerBalance).to.be.closeTo(ethers.parseEther("11800"), GAS_TOLERANCE);

    // // 验证 NFT 所有权
    const owner = await testERC721.ownerOf(tokenId);
    console.log("owner::", owner);
    expect(owner).to.equal(buyer.address);
}

async function erc20Pay() {
    const [deployer, seller, buyer] = await ethers.getSigners();
    await deployments.fixture(["depolyNftAuctionFactory", "upgradeNftAuction"]);

    const nftAuctionProxy = await deployments.get("NftAuctionProxyV2");
    const nftAuctionFactory = await ethers.getContractAt(
        "NftAuctionFactoryV2",
        nftAuctionProxy.address
    );

    // 1. 部署 ERC721 合约
    const TestERC721 = await ethers.getContractFactory("NFT");
    const testERC721 = await TestERC721.connect(deployer).deploy();
    await testERC721.waitForDeployment();
    const testERC721Address = await testERC721.getAddress();
    console.log("testERC721Address::", testERC721Address);
    // mint 10个 NFT
    for (let i = 0; i < 10; i++) {
        await testERC721.mintNFT(seller.address, i + '');
    }

    const tokenId = 1;   
    // 授权NFT给代理合约
    await testERC721.connect(seller).approve(nftAuctionProxy.address, tokenId);

    // 部署ERC20合约
    const ERC20 = await ethers.getContractFactory("ERC20");
    const erc20 = await ERC20.connect(deployer).deploy();
    await erc20.waitForDeployment();
    const erc20Address = await erc20.getAddress();
    console.log("erc20Address::", erc20Address);
    // mint 3000个 erc给buyer
    await erc20.mint(buyer, 3000);

    const autionId = "first aution";
    await nftAuctionFactory.connect(seller).createAuctionV2(
        autionId,
        testERC721Address,
        tokenId,
        Math.floor(Date.now() / 1000),
        20,
        10000
    );

    const auctionAddress = await nftAuctionFactory.getAuctionAddress(autionId);
    console.log("创建拍卖成功：：", auctionAddress);

    // 管理员设置chainlink喂价
    const AggregatorV3 = await ethers.getContractFactory("AggregatorV3");
    // 1ETH = 14000RMB, 8位精度
    const aggregatorV3 = await AggregatorV3.connect(deployer).deploy(14000 * (10**8));
    await aggregatorV3.waitForDeployment();
    const aggregatorV3Address = await aggregatorV3.getAddress();
    console.log("aggregatorV3Address::", aggregatorV3Address);
    // 1ERC = 7RMB, 8位精度
    const ercAggregatorV3 = await AggregatorV3.connect(deployer).deploy(7 * (10**8));
    await ercAggregatorV3.waitForDeployment();
    const ercAggregatorV3Address = await ercAggregatorV3.getAddress();
    console.log("ercAggregatorV3Address::", ercAggregatorV3Address);

    const nftAuctionV2 = await ethers.getContractAt("NftAuctionV2", auctionAddress);
    await nftAuctionV2.connect(deployer).setPriceFeed(erc20Address, ercAggregatorV3Address);
    await nftAuctionV2.connect(deployer).setPriceFeed(ethers.ZeroAddress, aggregatorV3Address);

    // 3. 购买者参与拍卖
    // 授权代币给拍卖合约
    await erc20.connect(buyer).approve(auctionAddress, 3000);
    // 竞价不够, 报错
    await expect(
      nftAuctionV2.connect(buyer).placeBid(erc20Address, 100)
    ).to.be.revertedWith("Bid must be higher than the current highest bid");
    // 成功竞价
    await nftAuctionV2.connect(buyer).placeBid(erc20Address, 2000)

    // 4. 结束拍卖
    // 等待
    await new Promise((resolve) => setTimeout(resolve, 25 * 1000));
    await nftAuctionV2.connect(seller).endAuction();
    const deployerBalance = await erc20.balanceOf(deployer);
    const buyerBalance = await erc20.balanceOf(buyer);
    const sellerBalance = await erc20.balanceOf(seller);
    console.log("deployer: ", deployerBalance);
    console.log("buyer: ", buyerBalance);
    console.log("seller: ", sellerBalance);
    // deployer得到200 erc手续费
    expect(deployerBalance).to.equal(200);
    // buyer失去2000 erc, 剩1000
    expect(buyerBalance).to.equal(1000);
    // seller得到1800 erc
    expect(sellerBalance).to.equal(1800);

    // // 验证 NFT 所有权
    const owner = await testERC721.ownerOf(tokenId);
    console.log("owner::", owner);
    expect(owner).to.equal(buyer.address);
}