pragma solidity ^0.4.0;
contract Escrow {
    
    //storage
    address public buyer;
    address public seller;
    uint public amount;
    uint public deposit;
    
    //events
    event BuyerDeposited(address from, string msg, uint amount);
    event SellerDeposited(address from, string msg, uint amount);
    event AmountSent(string msg);
    event SellerPaid(string msg);
    event BuyerRefunded(string msg);
    
    
    //initialise
    function Escrow(address _buyer, address _seller, uint _amount, uint _deposit) public {
        buyer = _buyer;
        seller = _seller;
        amount = _amount;
        deposit = _deposit;
        }
    
    //fallback
    function() public payable {
    }
    
    function buyerDeposit() public payable {
        require(msg.value == deposit && msg.sender == buyer);
        BuyerDeposited(msg.sender, "has made the required deposit of", msg.value);
    }
    
    function sellerDeposit() public payable {
        require(msg.value == deposit && msg.sender == seller);
        SellerDeposited(msg.sender, "has made the required deposit of", msg.value);
    }
    
    function sendAmount() public payable {
        require(msg.value == amount && msg.sender == buyer);
        AmountSent("Buyer has sent the payment to the escrow");
    }
    
    //complete transaction and return deposits
    function paySeller() public {
        if(msg.sender == buyer) {
            seller.transfer(amount);
            buyer.transfer(deposit);
            seller.transfer(deposit);
            SellerPaid("The seller has been paid and all deposits have been returned - transaction complete");
        }
    }
    
    //cancel transaction and return deposits
    function refundBuyer() public {
        if(msg.sender == seller) {
            buyer.transfer(amount);
            seller.transfer(deposit);
            buyer.transfer(deposit);
            BuyerRefunded("The buyer has been refunded and all deposits have been returned - transaction cancelled");
        }
    }
}
