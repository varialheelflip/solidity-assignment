const { ethers, deployments, getNamedAccounts } = require("hardhat")
const { expect } = require("chai")


describe("Test auction", async function () {
    it("Should be ok", async function () {
        await main();
    });
})

async function main() {
    const [deployer, seller, buyer] = await ethers.getSigners();
    await deployments.fixture(["depolyNftAuctionFactory"]);
    console.log("deployer地址", deployer.address);
    console.log("seller地址", seller.address);
    console.log("buyer地址", buyer.address);
    
    const nftAuctionProxy = await deployments.get("NftAuctionFactoryProxy");
    const nftAuctionFactory = await ethers.getContractAt(
        "NftAuctionFactory",
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
    await nftAuctionFactory.connect(seller).createAuction(
        autionId,
        testERC721Address,
        tokenId,
        Math.floor(Date.now() / 1000),
        15,
        ethers.parseEther("1000")
    );

    const auctionAddress = await nftAuctionFactory.getAuctionAddress(autionId);
    console.log("创建拍卖成功：：", auctionAddress);

    // 3. 购买者参与拍卖
    const nftAuction = await ethers.getContractAt(
        "NftAuction",
        auctionAddress
    );
    await nftAuction.connect(buyer).placeBid({ value: ethers.parseEther("2000") });

    // 4. 结束拍卖
    // 等待
    await new Promise((resolve) => setTimeout(resolve, 15 * 1000));
    await nftAuction.connect(seller).endAuction();
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