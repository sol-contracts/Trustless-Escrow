pragma solidity ^0.4.0;

import "./SafeMath.sol";

contract Escrow {
    
    
    // using Zepplin's SafeMath library to prevent overflow
    using SafeMath for uint;
    
    //---------------------------------------------------------------------------------------------
    
    
    //storage
    address public buyer;
    address public seller;
    address[] public party;
    uint public amount;
    uint public deposit;
    uint public signatureCount;
    mapping (address => bool) isAParty;
    mapping (address => uint) signatures;
    mapping (address => uint) depositCheck;
    mapping (address => uint) amountCheck;
    
    //---------------------------------------------------------------------------------------------
    
    
    //modifiers
    //only buyer can access
    modifier isBuyer() {
        require(msg.sender == buyer);
        _;
    }
    
    //only seller can access
    modifier isSeller() {
        require(msg.sender == seller);
        _;
    }
    
    //only the parties involved in the transaction can access.
    modifier ifIsAParty(address aParty) {
        require(isAParty[aParty]);
        _;
    }
    
    //---------------------------------------------------------------------------------------------
    
    
    //events
    event BuyerDeposited(address from, string msg, uint amount);
    event SellerDeposited(address from, string msg, uint amount);
    event BuyerDepositReversed(string msg);
    event SellerDepositReversed(string msg);
    event DepositPartialClaim(string msg);
    event DepositsClaimed(string msg);
    event AmountSent(string msg);
    event SellerPaid(string msg);
    event BuyerRefunded(string msg);
    
    //=============================================================================================
    
    
    /* initialising function - sets buyer, seller, 
    the amount to be transferred and amount to be deposited 
    AMOUNTS ARE CONVERTED TO ETHER
    Also sets the buyer and seller as the sole two parties to the transaction*/
    
    function Escrow(address _buyer, address _seller, uint _amount, uint _deposit) public {
        buyer = _buyer;
        seller = _seller;
        amount = (_amount.mul(1 ether));
        deposit = (_deposit.mul(1 ether));
        party.push(_buyer);
        party.push(_seller);
        isAParty[_buyer] = true;
        isAParty[_seller] = true;
        }
        
    //---------------------------------------------------------------------------------------------
    
    
    //fallback - can't send ether without specifying function.
    
    function() public payable {
        revert();
    }
    
    //---------------------------------------------------------------------------------------------
    
    
    /* Deposit function for the buyer - checks that the message sender
    is the buyer, the amount being sent is equal to the deposit amount
    and restricts the buyer from depositing more than once */
    
    function buyerDeposit() public payable isBuyer {
        require(msg.value == deposit);
        require(depositCheck[msg.sender] == 0);
        depositCheck[msg.sender] = 1;
        BuyerDeposited(msg.sender, "has made the required deposit of", msg.value);
    }
    
    //---------------------------------------------------------------------------------------------
    
    
    /* Deposit function for the seller - checks that the message sender
    is the aeller, the amount being sent is equal to the deposit amount
    and restricts the seller from depositing more than once */
    
    function sellerDeposit() public payable isSeller {
        require(msg.value == deposit);
        require(depositCheck[msg.sender] == 0);
        depositCheck[msg.sender] = 1;
        SellerDeposited(msg.sender, "has made the required deposit of", msg.value);
    }
    
    //---------------------------------------------------------------------------------------------
    
    
    /* Function for buyer to retrieve deposit in the scenario where only the
    buyer has interacted witht he contract and the transaction is no longer
    going ahead.*/
    
    function reverseBuyerDeposit() public isBuyer {
        require(depositCheck[buyer] == 1);
        require(depositCheck[seller] == 0);
        require(amountCheck[buyer] == 0);
        depositCheck[buyer] = 0;
        buyer.transfer(deposit);
        BuyerDepositReversed("the buyer has reversed their deposit");
    }
    
    //---------------------------------------------------------------------------------------------
    
    
    /* Function for seller to retrieve deposit in the scenario where only the
    seller has interacted witht he contract and the transaction is no longer
    going ahead.*/
    
    function reverseSellerDeposit() public isSeller {
        require(depositCheck[seller] == 1);
        require(depositCheck[buyer] == 0);
        require(amountCheck[buyer] == 0);
        depositCheck[seller] = 0;
        seller.transfer(deposit);
        SellerDepositReversed("the seller has reversed their deposit");
    }
    
    //---------------------------------------------------------------------------------------------
    
    
    /* Function for both parties to reverse their deposits when both the buyer
    and seller have made their deposits but no longer wish to proceed, both must
    sign off on this by calling this function*/
    
    function claimDeposits() public ifIsAParty(msg.sender) {
        require(depositCheck[buyer] ==1);
        require(depositCheck[seller] == 1);
        require(amountCheck[buyer] ==0);
        require(signatures[msg.sender] == 0);
        signatures[msg.sender] = 1;
        signatureCount ++;
        
        if (signatureCount == 1) {
            DepositPartialClaim("the deposit claim has 1 out of 2 necessary signatures");
        }
        
        if (signatureCount == 2) {
            buyer.transfer(deposit);
            seller.transfer(deposit);
            depositCheck[buyer] = 0;
            depositCheck[seller] = 0;
            signatures[buyer] = 0;
            signatures[seller] = 0;
            signatureCount = 0;
            DepositsClaimed("the deposits have been returned");
        }
    }
    
    //---------------------------------------------------------------------------------------------
    
    
    /* Function to allow the buyer to send the amount which is to eventually
    be transferred to the seller. Checks that the buyer is sending the correct
    amount, checks that both seller and buyer have made the required deposits 
    and restricts the buyer from making multiple payments */
    
    function sendAmount() public payable isBuyer {
        require(msg.value == amount);
        require(depositCheck[buyer] == 1);
        require(depositCheck[seller] == 1);
        require(amountCheck[msg.sender] == 0);
        amountCheck[msg.sender] = 1;
        AmountSent("Buyer has sent the payment amount to the escrow");
    }
    
    //---------------------------------------------------------------------------------------------
    
    
    /* complete transaction: transferring specified amount to the seller and 
    returning deposits to both parties */
    
    function paySeller() public isBuyer {
        require(depositCheck[buyer] == 1);
        require(depositCheck[seller] == 1);
        require(amountCheck[buyer] == 1);
        seller.transfer(amount);
        buyer.transfer(deposit);
        seller.transfer(deposit);
        SellerPaid("The seller has been paid and all deposits have been returned - transaction complete");
    }
    
    //---------------------------------------------------------------------------------------------
    
    
    /*cancel transaction: refunding the specified amount to the buyer and 
    returning deposits to both parties */
    
    function refundBuyer() public isSeller {
        require(depositCheck[buyer] == 1);
        require(depositCheck[seller] == 1);
        require(amountCheck[buyer] == 1);
        buyer.transfer(amount);
        seller.transfer(deposit);
        buyer.transfer(deposit);
        BuyerRefunded("The buyer has been refunded and all deposits have been returned - transaction cancelled");
    }
}
