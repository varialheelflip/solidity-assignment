const { ethers, upgrades } = require("hardhat")

module.exports = async function ({ getNamedAccounts, deployments }) {
  const { save } = deployments;
  const factoryProxy = await deployments.get("NftAuctionFactoryProxy");
  console.log("代理合约地址", factoryProxy.address);

  // 升级版的工厂合约
  const nftAuctionFactoryV2 = await ethers.getContractFactory("NftAuctionFactoryV2");

  // 升级代理合约
  const nftAuctionProxyV2 = await upgrades.upgradeProxy(factoryProxy.address, nftAuctionFactoryV2);
  await nftAuctionProxyV2.waitForDeployment();
  const proxyAddressV2 = await nftAuctionProxyV2.getAddress();
  console.log("这个地址应该不变吧:", proxyAddressV2);

  await save("NftAuctionProxyV2", {
    abi: nftAuctionFactoryV2.interface.format("json"),
    address: proxyAddressV2,
  })
}

module.exports.tags = ["upgradeNftAuction"]