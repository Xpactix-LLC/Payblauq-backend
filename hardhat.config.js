require("@nomicfoundation/hardhat-toolbox");

require("dotenv").config();

module.exports={
    solidity:"0.8.20",
    networks:{
        sepolia:{
            url:process.env.Api_key,
            accounts:[process.env.Secret_key],
           
        }
    }
    
  
}
