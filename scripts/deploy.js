const { ethers } = require("hardhat");

async function main() {
  const fundMeFactory = await ethers.getContractFactory("FundMe");
  console.log("Deploying Contract...");
  const fundMeContract = await fundMeFactory.deploy();
  await fundMeContract.deployed();
  console.log(`Deployed Contract to: ${fundMeContract.address}`);

  
}

main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.log(error);
    process.exit(1);
  });
