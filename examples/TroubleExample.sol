contract SimpleAuction {
    
    address public beneficiary;
    address public winner;
    uint public highestBid;
    uint auctionEndTime;
    bool public ended;
    
    constructor(uint _biddingTime) {
        beneficiary = payable(msg.sender);
        auctionEndTime = block.timestamp + _biddingTime;
    }
    
    function bid() external payable {
        require(ended == false, "The auction is over");
        require(beneficiary != msg.sender, "Bid not permitted from beneficiary");
        if(msg.value > highestBid){
            payable(winner).transfer(highestBid);
            winner = msg.sender;
            highestBid = msg.value;
        } else {
            // There is a problem with the line below, (risk security issue)
            // because we are performing the transfer ourselves,the problem is that 
            // we could run unreliable contracts when trying to send money with
            // this approach, instead it is better to let each one claim their own money
            payable(msg.sender).transfer(msg.value);
        }
    }
}