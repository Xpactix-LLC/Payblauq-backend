# Payblauq_Merchant Smart Contract Documentation

1. [Contract Overview](#contract-overview)
2. [Getting Started](#getting-started)
   - [Prerequisites](#Prerequisites)
   - [Installation](#Installation)
3. [Contract Structure](#contract-structure)
   - [State Variables](#state-variables)
   - [Structs](#structs)
   - [Modifiers](#modifiers)
   - [Events](#events)
4. [Public Functions](#public-functions)
 - [addMerchant()](#addMerchant)
 - [removeMerchant()](#removeMerchant)
 - [changeFees()](#changeFees)
 - [updateUsdtAddress()](#updateUsdtAddress)
 - [updateWbtcAddress()](#updateWbtcAddress)
 - [adminWithdraw()](#adminWithdraw)
 - [generatePaymentLink()](#generatePaymentLink)
 - [payWithLink()](#payWithLink)
 - [getBalance()](#getBalance)
 - [withdraw()](#withdraw)
5. [Usage](#usage)
6. [Security Considerations](#security-considerations)
7. [Contributing](#contributing)
8. [License](#license)
9. [Contact](#contact)



 ##  Contract Overview<a name="contract-overview"></a>
This repository contains a Solidity smart contract for a Web3 Payment Gateway. The contract allows merchants to generate payment links, receive payments in USDT (a popular stablecoin), and withdraw their balances. It is built on the Ethereum blockchain and uses the OpenZeppelin library for enhanced security and functionality.
The contract also inherits some functions from the ERC20 USDT contract in the same folder,this used for testing purposes, to allow the contract recieve balances in USDT.The erc20 USDT contract should be deployed first, and the address should be used for the interface in deploying the merchant contract.

## Getting Started<a name="getting-started"></a>

### Prerequisites<a name="Prerequisites"></a>

To interact with this contract, you'll need:

- An Ethereum wallet (e.g., MetaMask) with some test ETH for gas fees.
- USDT (or an equivalent test token) for testing payments.

### Installation<a name="Installation"></a>

- Clone the repository:
   https://github.com/Xpactix-LLC/Payblauq-backend.git

- Install the dependencies using `npm install`

- Fetch your `wallet private keys` and `node provider api keys` (Alchemy or Infura)

- Create a .env folder and insert them using the variables on the hardhat config file

- Run `npm run scrips/deploy --network sepolia` on your command line to compile and deploy the smart contracts.

- The contract would be succesfully deployed to the contract address on your command line.

  
## Contract Structure<a name="contract-structure"></a>
The Payblauq_Merchant smart contract consists of the following components:

### State Variables<a name="state-variables"></a>
`owner`: The address that deployed the contract.<br>
`usdtAddress`: The address of the USDT token contract.<br>
`wbtcAddress`:  The address of the wbtc tokeb contract.<br>
`totalNumMerchants`: A public variable that stores the total number of registered merchants.<br>
`currentFeesinPercentage` A public variable that stores the current transaction fee for transactions.<br>
`currentPaymentId`: A state variable that is used to keep track of the current payment identifier. it is initialized to `0` and is then incremented each time a new payment link is generated.
`totalTransaction` A public variable that keeps track of the overall activity of the contract by counting the total number of successful payment transaction.
`currencyType`:  An enum that sets the types of crypto currencies accepted by the platform.
`merchant`: This mapping tracks whether an address is a merchant or not.<br>
`totalAmountUSDTTransaction`:   This mapping track the total transaction amounts for each merchant in USDT.<br>
`totalAmountWBTCTransaction` :  This mapping track the total transaction amounts for each merchant in WBTC.<br>
`totalAmountETHERTransaction`:  This mapping track the total transaction amounts for each merchant in Ethers.<br>
`totalMerchantTransaction`   :  This mapping tracks the total number of transactions for each merchant.
`paymentDetails`: A mapping of link IDs to payment details.<br>


### Structs<a name="structs"></a>
- `payment`: Represent information about an active payment that is going to be made from a sender to the Merchant, it includes the amount,address of the receiving merchant,payment Id, currency type and transaction time
### Modifiers<a name="modifiers"></a>
- `onlyOwner`- Allows only the deploying address to have access to some functions.
- `onlyMerchants`- Allows only registered Merchants to have access to some functions.
### Events<a name="events"></a>
The contract emits various events to provide information about important contract actions and state changes. These events can be subscribed to by external applications to track the contract's activities.

## Public Functions<a name="public-functions"></a>
The Payblauq_Merchants smart contract exposes the following public functions for external interaction:

### `addMerchant()`<a name="addMerchant"></a>
```solidity
 function addMerchant() external
```
Merchants can be added to the platform 

### `removeMerchant()`<a name="removeMerchant"></a>
```solidity
   function removeMerchant(address merchantAddress) external onlyOwner
```
Merchants can be removed from the platform by the owner.

### `changeFees()`<a name="changeFees"></a>
```solidity
   function changeFees(uint256 percentage) external onlyOwner
```
Allows ownwer of the contract to update the transaction fees

### `updateUsdtAddress()`<a name="updateUsdtAddress"></a>
``` solidity
    function updateUsdtAddress(address newUsdtAddress) external onlyOwner
```
Owner can update the USDT address on ethereum incase of a fork or changes on the layer 1 blockchain.

### `updateWbtcAddress()`<a name="updateWbtcAddress()"></a>

### `adminWithdraw()`<a name="adminWithdraw"></a>

### `generatePaymentLink()`<a name="generatePaymentLink"></a>
```solidity
  function generatePaymentLink(uint256 amountInUsdt) onlyMerchant external returns (bytes32)
```
Merchants can generate payment link with this function which can be sent to any customer for payment, this functions takes in the amount as variable and returns a hash of the payment details.

### `payWithLink()`<a name="payWithLink"></a>
```solidity
 function payWithLink(bytes32 linkId) external
```
Customers can pay Merchants through the link ID generated by the merchants.

### `getBalance()`<a name="getBalance"></a>
```solidity
 function getBalance() external view returns (uint256)
```
This tracks the amount of USDT the Merchants has in thier respective accounts.


### `withdraw()`<a name="withdraw"></a>
```solidity
 function withdraw(uint256 amount) external onlyMerchant
```
Merchants can withdraw USDT sent to them by customers with this function

## Usage
- Deploy the smart contract using an Ethereum development environment.
- Add merchants to the contract using the `addMerchant()` function.
- Merchants can generate payment links using the `generatePaymentLink()` function.
- Users can use the generated links to pay using the `payWithLink()` function.
- Merchants can check their balances using the `getBalance()` function.
- Merchants can withdraw their balances using the `withdraw()` function.

## Security Considerations<a name="security-considerations"></a>

When using the Payblauq_Merchant smart contract, it's essential to consider the following security aspects:

1. Carefully review and audit the contract code to identify and address potential vulnerabilities.
2. Protect private keys associated with company and picker addresses to prevent unauthorized access.
3. Implement proper access control mechanisms to ensure that only authorized entities can perform specific actions.
4. Use secure communication channels and protocols when interacting with the contract.
5. Be cautious of potential reentrancy attacks and ensure the `noReentrancy` modifier is correctly applied to susceptible functions.
6. Regularly update and patch the smart contract as needed to address any identified security issues or improvements.

By following these security considerations, you can enhance the overall security and reliability of the Payblauq_Merchant smart contract in your application.

### Contributing<a name="contributing"></a>
Contributions are welcome! If you find any issues or want to enhance the contract, follow these steps:

- Fork the repository.
- Create a new branch: git checkout -b feature/your-feature-name
- Make changes and commit them: git commit -m 'Add some feature'
- Push to the branch: git push origin feature/your-feature-name
- Create a pull request. <br>

### License<a name="license"></a>
This project is licensed under the MIT License.

### Contact<a name="contact"></a>
For questions or support, you can reach out to the repository owner:

- Email: john@xpactix.com
- GitHub: Xpactix-LLC
