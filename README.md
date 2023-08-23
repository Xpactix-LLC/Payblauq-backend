# Payblauq_Merchant

This repository contains a Solidity smart contract for a Web3 Payment Gateway. The contract allows merchants to generate payment links, receive payments in USDT (a popular stablecoin), and withdraw their balances. It is built on the Ethereum blockchain and uses the OpenZeppelin library for enhanced security and functionality.
The contract also inherits some functions from the ERC20 USDT contract in the same folder,this used for testing purposes, to allow the contract recieve balances in USDT.The erc20 USDT contract should be deployed first, and the address should be used for the interface in deploying the merchant contract.

## Features

- Merchants can register and be added to the list of authorized merchants.
- Merchants can generate payment links for specific amounts in USDT.
- Users can pay using generated payment links, and the USDT payment is credited to the merchant's balance.
- Merchants can withdraw their USDT balances.

## Getting Started

### Prerequisites

To interact with this contract, you'll need:

- An Ethereum wallet (e.g., MetaMask) with some test ETH for gas fees.
- USDT (or an equivalent test token) for testing payments.

### Installation

- Clone the repository:
   https://github.com/Xpactix-LLC/Payblauq-backend.git

- Install the dependencies using `npm install`

- Fetch your `wallet private keys` and `node provider api keys` (Alchemy or Infura)

- Create a .env folder and insert them using the variables on the hardhat config file

- Run `npm run scrips/deploy --network sepolia` on your command line to compile and deploy the smart contracts.

- The contract would be succesfully deployed to the contract address on your command line.



### Usage
- Deploy the smart contract using an Ethereum development environment.
- Add merchants to the contract using the `addMerchant()` function.
- Merchants can generate payment links using the `generatePaymentLink()` function.
- Users can use the generated links to pay using the `payWithLink()` function.
- Merchants can check their balances using the `getBalance()` function.
- Merchants can withdraw their balances using the `withdraw()` function.

### Smart Contract Details
`owner`: The address that deployed the contract.<br>
`usdtAddress`: The address of the USDT token contract.<br>
`merchant`s: A mapping of addresses to merchant status.<br>
`usdtBalance`s: A mapping of merchant addresses to their USDT balances.<br>
`paymentDetails`: A mapping of link IDs to payment details.<br>

### Contributing
Contributions are welcome! If you find any issues or want to enhance the contract, follow these steps:

- Fork the repository.
- Create a new branch: git checkout -b feature/your-feature-name
- Make changes and commit them: git commit -m 'Add some feature'
- Push to the branch: git push origin feature/your-feature-name
- Create a pull request. <br>

### License
This project is licensed under the MIT License.

### Contact
For questions or support, you can reach out to the repository owner:

- Email: john@xpactix.com
- GitHub: Xpactix-LLC
