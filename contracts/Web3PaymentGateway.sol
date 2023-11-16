// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

interface IERC20 {
    function transfer(address recipient, uint256 amount) external returns (bool);
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);
    function balanceOf(address account) external view returns (uint256);
}

contract Payblauq_Merchant is ReentrancyGuard,Ownable {
    address public usdtAddress;
    address public wbtcAddress;
    uint256 public totalNumMerchant; 
    uint256 public currentFeesinPercentage=1;
    uint256 public currentPaymentId = 0;
    uint256 public totalTransactions;

    enum CurrencyType { Ether, USDT, WBTC}

    

    mapping(address=>bool) public merchant;
    mapping(address => uint256) public totalAmountUSDTTransaction;
    mapping(address => uint256) public totalAmountWBTCTransaction;
    mapping(address => uint256) public totalAmountETHERTransaction;
    mapping(address=>uint256) public totalMerchantTransaction;
    mapping(bytes32 => Payment) public paymentDetails;

    struct Payment {
        uint256 amount;
        address merchantAddress;
        uint256 paymentId;
        CurrencyType currency;
        uint256 transactionTime;
    }
    modifier onlyMerchant(){
        require(merchant[msg.sender] == true, "Caller is not a merchant");
        _;
    }


    event MerchantAdded(address indexed merchantAddress, uint256 time);
    event MerchantRemoved(address indexed merchantAddress, uint256 time);
    event FeesChanged(uint256 currentFees, uint256 timeChanged);
    event AdminWithdraw(uint256 amountWithdrawn,address withdrawaAddress,uint256 time);
    event MerchantWithdraw(uint256 amountWithdrawn,address indexed merchant,CurrencyType currency,uint256 time);
    event PaymentReceived(address indexed from, uint256 amount, CurrencyType currency);
    event PaymentLinkGenerated(bytes32 indexed linkId, address indexed merchant, uint256 amountTokens, uint256 currentPaymentId,CurrencyType currency,uint256 transactionTime);
    event TokenAddressUpdated(string tokenType, address newAddress);


    constructor(address initialOwner,address _usdtAddress,address _wbtcAddress) Ownable(initialOwner) {
        usdtAddress = _usdtAddress;
        wbtcAddress = _wbtcAddress;
       
       
       

    }
    
    function addMerchant(address merchantAddress) external {
        require(merchant[merchantAddress]==false,"Address is already a Merchant");
        require(merchantAddress != address(0), "Address is not valid");
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
    function changeFees(uint256 percentage) external onlyOwner{
        currentFeesinPercentage=percentage;
        emit FeesChanged(percentage,block.timestamp);

       
    }

    function updateUsdtAddress(address newUsdtAddress) external onlyOwner {
    require(newUsdtAddress != address(0), "New USDT address cannot be zero address");
    require(newUsdtAddress != usdtAddress, "New USDT address must be different");
    usdtAddress = newUsdtAddress;
    emit TokenAddressUpdated("USDT", newUsdtAddress);
    }

   function updateWbtcAddress(address newWbtcAddress) external onlyOwner {
    require(newWbtcAddress != address(0), "New WBTC address cannot be zero address");
    require(newWbtcAddress != wbtcAddress, "New WBTC address must be different");
    wbtcAddress = newWbtcAddress;
    emit TokenAddressUpdated("WBTC", newWbtcAddress);
    }

    function adminWithdraw(address withdrawalAddress, uint256 amount, CurrencyType currency) external onlyOwner nonReentrant {
    require(amount > 0, "Withdrawal amount must be greater than 0");

    if (currency == CurrencyType.USDT) {
         IERC20 usdt = IERC20(usdtAddress);
        uint256 balance = usdt.balanceOf(address(this));
        require(balance >= amount, "Insufficient USDT balance");
        require(usdt.transfer(withdrawalAddress, amount), "USDT transfer failed");
    }
    else if (currency == CurrencyType.WBTC) {
         IERC20 wbtc = IERC20(wbtcAddress);
        uint256 balance = wbtc.balanceOf(address(this));
        require(balance >= amount, "Insufficient WBTC balance");
        require(wbtc.transfer(withdrawalAddress, amount), "WBTC transfer failed");
    }
    else if (currency == CurrencyType.Ether) {
        uint256 balance = address(this).balance;
        require(balance >= amount, "Insufficient Ether balance");
        payable(withdrawalAddress).transfer(amount);
    }

    emit AdminWithdraw(amount, withdrawalAddress, block.timestamp);
    }
    function merchantWithdraw(uint256 amount, CurrencyType currency ) external onlyMerchant nonReentrant{
        require(amount > 0, "Withdrawal amount must be greater than 0");
        if (currency == CurrencyType.USDT) {
        IERC20 usdt = IERC20(usdtAddress);
        uint256 balance = totalAmountUSDTTransaction[msg.sender];
        require(balance >= amount, "Insufficient USDT balance");
        require(usdt.transfer(msg.sender, amount), "USDT transfer failed");
        totalAmountUSDTTransaction[msg.sender]-=amount;
    }
        else if (currency == CurrencyType.WBTC) {
        IERC20 wbtc = IERC20(wbtcAddress);
        uint256 balance = totalAmountWBTCTransaction[msg.sender];
        require(balance >= amount, "Insufficient WBTC balance");
        require(wbtc.transfer(msg.sender, amount), "WBTC transfer failed");
        totalAmountWBTCTransaction[msg.sender]-=amount;
    }
        else if (currency == CurrencyType.Ether) {
        uint256 balance = totalAmountETHERTransaction[msg.sender];
        require(balance >= amount, "Insufficient Ether balance");
        payable(msg.sender).transfer(amount);
        totalAmountETHERTransaction[msg.sender]-=amount;
    }
    emit MerchantWithdraw(amount,msg.sender, currency,block.timestamp);
    }
    
    function generatePaymentLink(uint256 amountTokens,CurrencyType currency) external  onlyMerchant returns (bytes32) {
        require(amountTokens > 0, "Amount must be greater than 0.");
         currentPaymentId++;
        Payment memory newPayment = Payment({
            amount: amountTokens,
            merchantAddress: msg.sender,
            paymentId: currentPaymentId,
            currency: currency,
            transactionTime:block.timestamp
        });
        bytes32 linkId = keccak256(abi.encodePacked(msg.sender, amountTokens,currentPaymentId,currency));
        paymentDetails[linkId] = newPayment;
        emit PaymentLinkGenerated(linkId, msg.sender, amountTokens,currentPaymentId,currency,block.timestamp);
        return linkId;
    }

    function payWithLink(bytes32 linkId) external payable nonReentrant {
        require(paymentDetails[linkId].amount > 0, "Invalid payment link.");
        Payment memory payment = paymentDetails[linkId];
        uint256 fee=(payment.amount*currentFeesinPercentage)/100;
        uint256 amountAfterFee = payment.amount - fee;
        if (payment.currency == CurrencyType.USDT) {
            IERC20 usdt = IERC20(usdtAddress);
            require(usdt.transferFrom(msg.sender,address(this),payment.amount),"Payment transfer failed");
            totalAmountUSDTTransaction[payment.merchantAddress]+=amountAfterFee;
        } else if (payment.currency == CurrencyType.WBTC) {
            IERC20 wbtc = IERC20(wbtcAddress);
            require(wbtc.transferFrom(msg.sender,address(this),payment.amount),"Payment transfer failed");
            totalAmountWBTCTransaction[payment.merchantAddress]+=amountAfterFee;
        } else if (payment.currency == CurrencyType.Ether) {
            totalAmountETHERTransaction[payment.merchantAddress]+=amountAfterFee;
        }

        totalTransactions++;
        totalMerchantTransaction[payment.merchantAddress]++;
        emit PaymentReceived(msg.sender, payment.amount, payment.currency);
    }
}
