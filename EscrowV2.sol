pragma solidity ^0.4.0;

contract Escrow {
    
    //storage
    address public buyer;
    address public seller;
    uint public amount;
    uint public deposit;
    mapping (address => uint) depositCheck;
    mapping (address => uint) amountCheck;
    
    //---------------------------------------------------------------------------------------------
    
    //modifiers
    modifier isBuyer() {
        require(msg.sender == buyer);
        _;
    }
    
    //---------------------------------------------------------------------------------------------
    
    modifier isSeller() {
        require(msg.sender == seller);
        _;
    }
    
    //---------------------------------------------------------------------------------------------
    
    //events
    event BuyerDeposited(address from, string msg, uint amount);
    event SellerDeposited(address from, string msg, uint amount);
    event AmountSent(string msg);
    event SellerPaid(string msg);
    event BuyerRefunded(string msg);
    
    //=============================================================================================
    
    /* initialising function - sets buyer, seller, 
    the amount to be transferred and amount to be deposited */
    function Escrow(address _buyer, address _seller, uint _amount, uint _deposit) public {
        buyer = _buyer;
        seller = _seller;
        amount = _amount;
        deposit = _deposit;
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
        require(amountCheck[msg.sender] == 1);
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
        require(amountCheck[msg.sender] == 1);
        buyer.transfer(amount);
        seller.transfer(deposit);
        buyer.transfer(deposit);
        BuyerRefunded("The buyer has been refunded and all deposits have been returned - transaction cancelled");
    }
}
