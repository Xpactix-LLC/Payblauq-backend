// We require the Hardhat Runtime Environment explicitly here. This is optional
// but useful for running the script in a standalone fashion through `node <script>`.
//
// You can also run a script with `npx hardhat run <script>`. If you do that, Hardhat
// will compile your contracts, add the Hardhat Runtime Environment's members to the
// global scope, and execute the script.

const hre = require("hardhat");

const main=async() =>{
  const testUSDT = await hre.ethers.getContractFactory("testUSDT");
  const TESTUSDT = await testUSDT.deploy("testUSDT","USDT","1000000000000000000000");

  await TESTUSDT.waitForDeployment();
  console.log("testUSDT deployed to:",await TESTUSDT.getAddress())

  // second contract
  
  const paymentGateway = await hre.ethers.getContractFactory("Payblauq_Merchant");
  const PAYMENTGATEWAY = await paymentGateway.deploy(await TESTUSDT.getAddress());

  await PAYMENTGATEWAY.waitForDeployment();
  console.log("Payment Gateway deployed to:",await PAYMENTGATEWAY.getAddress())


}


const runMain=async()=>{
  try {
    await main();
    process.exit(0);
    
  } catch (error) {
    console.error(error);
    process.exit(1);
    
  }
}
runMain();














































