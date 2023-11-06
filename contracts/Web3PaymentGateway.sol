// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/access/AccessControl.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

interface IERC20 {
    function transfer(address recipient, uint256 amount) external returns (bool);
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);
    function balanceOf(address account) external view returns (uint256);
}

contract Payblauq_Merchant is ReentrancyGuard,Ownable {
    address public usdtAddress;
    uint256 public totalNumMerchant; 
    uint256 public totalTransactions;
    mapping(address=>bool) public merchant;
    mapping(address => uint256) public totalAmountMerchantTransaction;
    mapping(address=>uint256) public totalMerchantTransaction;
    mapping(bytes32 => Payment) public paymentDetails;

    struct Payment {
        uint256 amount;
        address merchantAddress;
        uint256 linkGeneratingTime;   
    }
    modifier onlyMerchant(){
        require(merchant[msg.sender] == true, "Caller is not a merchant");
        _;
    }


    event MerchantAdded(address indexed merchantAddress, uint256 time);
    event MerchantRemoved(address indexed merchantAddress, uint256 time);
    event PaymentReceived(address indexed from, uint256 amountInUSDT);
    event PaymentLinkGenerated(bytes32 indexed linkId, address indexed merchant, uint256 amountInUSDT, uint256 linkGeneratingTime);

    constructor(address _usdtAddress) {
        usdtAddress = _usdtAddress;
    }
    
    function addMerchant(address merchantAddress) external {
        require(merchant[merchantAddress]==false,"Address is already a Merchant");
        merchant[merchantAddress]=true;
        totalNumMerchant+=1;
        emit MerchantAdded(merchantAddress, block.timestamp); 
    }

    function removeMerchant(address merchantAddress) external onlyOwner {
        require(merchant[merchantAddress]==true,"Address is not a Merchant");
        require(totalNumMerchant>0,"Merchant number is 0");
        merchant[merchantAddress]=false;
        totalNumMerchant-=1;
        emit MerchantRemoved(merchantAddress, block.timestamp);
    }

    function generatePaymentLink(uint256 amountInUsdt) external  onlyMerchant returns (bytes32) {
        require(amountInUsdt > 0, "Amount must be greater than 0.");
        Payment memory newPayment = Payment({
            amount: amountInUsdt,
            merchantAddress: msg.sender,
            linkGeneratingTime: block.timestamp
        });
        bytes32 linkId = keccak256(abi.encodePacked(msg.sender, amountInUsdt,block.timestamp));
        paymentDetails[linkId] = newPayment;
        emit PaymentLinkGenerated(linkId, msg.sender, amountInUsdt,block.timestamp);
        return linkId;
    }

    function payWithLink(bytes32 linkId) external nonReentrant {
        require(paymentDetails[linkId].amount > 0, "Invalid payment link.");
        uint256 amountInUSDT = paymentDetails[linkId].amount;
        IERC20 usdt = IERC20(usdtAddress);
        require(usdt.transferFrom(msg.sender, paymentDetails[linkId].merchantAddress, amountInUSDT), "USDT transfer failed");
        totalAmountMerchantTransaction[paymentDetails[linkId].merchantAddress] += amountInUSDT;
        totalTransactions+=1;
        totalMerchantTransaction[paymentDetails[linkId].merchantAddress]+=1;
        emit PaymentReceived(msg.sender, amountInUSDT);
    }
}
