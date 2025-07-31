const { deployments, upgrades, ethers } = require("hardhat");

module.exports = async ({ getNamedAccounts, deployments }) => {
  const { save } = deployments;
  const { deployer } = await getNamedAccounts();

  const nftAuctionFactory = await ethers.getContractFactory("NftAuctionFactory");

  // 通过代理合约部署
  const NftAuctionProxy = await upgrades.deployProxy(nftAuctionFactory, [], {
    initializer: "initialize",
  })
  
  await NftAuctionProxy.waitForDeployment();

  const proxyAddress = await NftAuctionProxy.getAddress()
  const implAddress = await upgrades.erc1967.getImplementationAddress(proxyAddress)
  console.log("部署NftAuctionFactory成功");
  console.log("部署用户地址：", deployer);
  console.log("代理合约地址：", proxyAddress);
  console.log("实现合约地址：", implAddress);
  await save("NftAuctionFactoryProxy", {
    abi: nftAuctionFactory.interface.format("json"),
    address: proxyAddress,
  })
};


module.exports.tags = ["depolyNftAuctionFactory"];
