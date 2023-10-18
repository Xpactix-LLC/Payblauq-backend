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

contract Payblauq_Merchant is ReentrancyGuard, AccessControl, Ownable {
    bytes32 public constant MERCHANT_ROLE = keccak256("MERCHANT_ROLE");
    address public usdtAddress;

    mapping(address => uint256) public usdtBalances;
    mapping(bytes32 => Payment) public paymentDetails;

    struct Payment {
        uint256 amount;
        address merchantAddress;
    }

    event MerchantAdded(address indexed merchantAddress, uint256 time);
    event MerchantRemoved(address indexed merchantAddress, uint256 time);
    event PaymentReceived(address indexed from, uint256 amountInUSDT);
    event PaymentLinkGenerated(bytes32 indexed linkId, address indexed merchant, uint256 amountInUSDT);

    constructor(address _usdtAddress) {
        usdtAddress = _usdtAddress;
        _setupRole(DEFAULT_ADMIN_ROLE, msg.sender);
    }

    function addMerchant(address merchantAddress) external {
        grantRole(MERCHANT_ROLE, merchantAddress);
        emit MerchantAdded(merchantAddress, block.timestamp); 
    }

    function removeMerchant(address merchantAddress) external onlyOwner {
        revokeRole(MERCHANT_ROLE, merchantAddress);
        emit MerchantRemoved(merchantAddress, block.timestamp);
    }

    function totalReceived() external view returns (uint256) {
        return usdtBalances[msg.sender];
    }

    function generatePaymentLink(uint256 amountInUsdt) external onlyRole(MERCHANT_ROLE) returns (bytes32) {
        require(amountInUsdt > 0, "Amount must be greater than 0.");

        Payment memory newPayment = Payment({
            amount: amountInUsdt,
            merchantAddress: msg.sender
        });

        bytes32 linkId = keccak256(abi.encodePacked(msg.sender, amountInUsdt));
        paymentDetails[linkId] = newPayment;
        emit PaymentLinkGenerated(linkId, msg.sender, amountInUsdt);
        return linkId;
    }

    function payWithLink(bytes32 linkId) external nonReentrant {
        require(paymentDetails[linkId].amount > 0, "Invalid payment link.");
        uint256 amountInUSDT = paymentDetails[linkId].amount;

        IERC20 usdt = IERC20(usdtAddress);
        require(usdt.transferFrom(msg.sender, paymentDetails[linkId].merchantAddress, amountInUSDT), "USDT transfer failed");
        usdtBalances[paymentDetails[linkId].merchantAddress] += amountInUSDT;
        emit PaymentReceived(msg.sender, amountInUSDT);
    }
}
