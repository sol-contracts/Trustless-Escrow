# Decentralised Trustless Escrow

This smart-contract (built for the Ethereum blockchain) creates an immutable and transparent two-party escrow system which *does not* rely on a third party in which the transacting parties must place their trust. This is achieved by incorporating dual-party deposits, which from a game theoretical point of view aligns the individual interests of both parties, incentivising them to complete the transaction in a trustworthy manner.

## Escrows
An **escrow** is a third party which acts as an intermediary between two transacting parties. The transacting parties place their trust in the third party and deposits their funds to the escrow which acts impartially and ensures that the transaction is not corrupted. The escrow then releases the funds when both parties are satisfied. In return the escrow is usually paid a fee for its services. 

## How The Smart Contract Works
The initialisation of the smart-contract requires four inputs:
1. The address of the Buyer.
2. The address of the Seller.
3. The amount which is to be transferred to the seller on completion (the price).
4. The deposit amount.

The buyer and seller must send the deposit amount to the smart-contract via the correct function calls. For this piece of logic there are 4 possible outcomes:
1. The buyer deposits but the seller does not.
2. The seller deposits but the buyer does not.
3. Both parties deposit but the decide to cancel the transaction.
4. Both parties deposit and proceed with the transaction.

In scenarios **1** and **2** the parties can claim their deposits back.
In scenario **3** both parties must sign off on the “claimDeposits” function which will return both parties their deposits.
In scenario **4** the buyer is then able to progress the transaction by sending the amount (price) which is to be transferred to the seller once the transaction is complete.

Once the deposits and the specified amount (price) has been sent, the smart contract will effectively act as an escrow and lock these funds. The only way that these can be released is if:
* The buyer agrees to send the specified amount (price) to the seller.

**or**
* The seller chooses to terminate the transaction and return the specified amount (price) to the buyer.
Once either of these are triggered the amount (price) is transferred accordingly and the deposits are returned to the parties.

## Game Theoretical Perspective
In order to demonstrate how game theory dictates that this mechanism will result in the optimal outcome let us use a simple example:
### Suppose **A** is *purchasing* a computer *from* **B** for the *price of 1 ether* and both parties agree on a deposit amount of *0.5 ether*. 

We also have a few main assumptions: 
1. The buyer and seller monitor each others interactions with the smart-contract.
2. Both parties are rational.
3. The deposits are not considered to be sunk costs as they can be recouped.

There are two main games here:

#### The Deposit Game:
A game only exists once both **A** and **B** have made deposits, at this point they can decide to proceed or abandon the transaction. Recall that both parties have made deposits and the only way to reclaim them is via proceeding with the transaction or agreeing to abandon it.
                              
|             |             |    **A**    |             | 
| ----------- | ----------- | ----------- | ----------- |
|             |             |Proceed      |Abandon      |
|  **B**      |Proceed      |0,0          |-0.5, -0.5   |
|             |Abandon      |-0.5. -0.5   |0.5, 0.5     |
             
             
Thus the design of the smart-contract incentivises both parties to come to a consensus to either cancel the transaction thus returning **A** and **B** their deposits, or proceeding with the transaction which has 2 outcomes in which both parties are returned their deposits. 

If **A** and **B** disagree the deposits are locked in the smart contracts and both parties make a loss.

#### The Transaction Game:
Once both deposits have been made and the buyer, **A** has transferred the “price” amount to the smart contract the parties can progress to the transaction. At this stage the parties can choose to complete or cancel the transaction.

|               |               |       **A**      |               |                     
| ------------- | ------------- | ---------------- | ------------- |
|               |               |Complete          |No Action      |
|   **B**       |No Action      |Item + 0.5, 1     |-1.5, -0.5     |
|               |Cancel         |Not possible      |1.5, 0.5       |

Only the buyer (**A**) can trigger the function to complete the transaction which sends the seller the amount, and returns the deposits to both parties. The buyer is incentivised to do this due to the return of their deposit, not doing this means that **A** will lose their deposit for no gain. 

The other possible settlement is that the seller (**B**) decides to cancel the transaction returning the “price” amount to the buyer and deposits to both parties, not doing this means that the seller will lose their deposit for no additional gain.

**A** and **B** could chose to do nothing and leave their funds locked in the smart contract, however there is no rational benefit to doing this.

Thus the smart contract incentivises both parties to come to an agreement.

## Notes
The input values for deposit and price are converted to ether by the smart contract.

Preliminary testing has been done, however please conduct your own testing before implementation.
