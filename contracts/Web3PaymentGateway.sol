// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

// Import the SafeMath library for performing arithmetic operations with safety checks.
import "@openzeppelin/contracts/utils/math/SafeMath.sol";
// import reentrancyguard to the contract
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";

// import AccessControl library to contrac
import "@openzeppelin/contracts/access/AccessControl.sol";

interface IERC20 {
    function transfer(address recipient, uint256 amount) external returns (bool);
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);
    function balanceOf(address account) external view returns (uint256);
}

contract Payblauq_Merchant is ReentrancyGuard, AccessControl {
    using SafeMath for uint256;

    address public owner;
    address public usdtAddress;

    mapping(address => bool) public merchants;
    mapping(address => uint256) public usdtBalances;
    mapping(bytes32 => Payment) public paymentDetails;

    struct Payment {
        uint256 amount;
        address merchantAddress;
    }

    event MerchantAdded(address indexed merchantAddress, uint256 time);
    event MerchantRemoved(address indexed merchantAddress, uint256 time);
    event PaymentReceived(address indexed from, uint256 amountInUSDT);
    event Withdrawal(address indexed to, uint256 amount);
    event PaymentLinkGenerated(bytes32 indexed linkId, address indexed merchant, uint256 amountInUSDT);

    constructor(address _usdtAddress) {
        owner = msg.sender;
        usdtAddress = _usdtAddress;
    }

    modifier onlyOwner() {
        require(msg.sender == owner, "Only the contract owner can call this function");
        _;
    }

    modifier onlyMerchant() {
        require(merchants[msg.sender] == true, "Only merchants can call this function");
        _;
    }

    function addMerchant() external {
        merchants[msg.sender] = true;
        emit MerchantAdded(msg.sender, block.timestamp);
    }

    function removeMerchant(address merchantAddress) external onlyOwner {
        merchants[merchantAddress] = false;
        emit MerchantRemoved(merchantAddress, block.timestamp);
    }

    function withdraw(uint256 amount) external onlyMerchant {
        require(amount > 0, "Amount must be greater than 0.");
        require(amount <= usdtBalances[msg.sender], "Insufficient balance.");
        
        usdtBalances[msg.sender] = usdtBalances[msg.sender].sub(amount);
        IERC20 usdt = IERC20(usdtAddress);
        require(usdt.transfer(msg.sender, amount), "USDT transfer failed");
        emit Withdrawal(msg.sender, amount);
    }

    function getBalance() external view returns (uint256) {
        return usdtBalances[msg.sender];
    }

    function generatePaymentLink(uint256 amountInUsdt) onlyMerchant external returns (bytes32) {
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

    function payWithLink(bytes32 linkId) external {
        require(paymentDetails[linkId].amount > 0, "Invalid payment link.");
        uint256 amountInUSDT = paymentDetails[linkId].amount;

        IERC20 usdt = IERC20(usdtAddress);
        require(usdt.transferFrom(msg.sender, address(this), amountInUSDT), "USDT transfer failed");
        usdtBalances[paymentDetails[linkId].merchantAddress] = usdtBalances[paymentDetails[linkId].merchantAddress].add(amountInUSDT);
        emit PaymentReceived(msg.sender, amountInUSDT);
    }
}
