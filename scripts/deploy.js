
const main=async() =>{
  const testUSDT = await hre.ethers.getContractFactory("testUSDT");
  const testUsdt = await testUSDT.deploy("USDT","USDT","10000000000000000000000000");

  await testUsdt.deployed();
  console.log("USDT deployed to:", testUsdt.address)

  
  
  // const PaymentGateway= await hre.ethers.getContractFactory("Web3PaymentGateway");
  // const paymentGateway = await PaymentGateway.deploy(testUsdt.address);

  // await paymentGateway.deployed();
  // console.log("PaymentGateway deployed to:", paymentGateway.address)


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