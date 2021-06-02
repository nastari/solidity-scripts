pragma solidity ^0.8.4;


contract SimpleAuction {
    
    address public beneficiary;
    uint public auctionEndTime;
    
    address public winner;
    uint public highestBid;

    mapping( address => uint ) bids;
    
    error BidWeak();
    
    constructor(uint _biddingTime, address _beneficiary ) {
        beneficiary = payable(_beneficiary);
        auctionEndTime = block.timestamp + _biddingTime;
    }
    
    function bid() external payable {
        require(block.timestamp < auctionEndTime, "The auction is over");
        require(beneficiary != msg.sender, "Bid not permitted from beneficiary");
        if(msg.value > highestBid){
            winner = msg.sender;
            highestBid = bids[msg.sender] + msg.value;
            bids[msg.sender] = bids[msg.sender] + msg.value;
        } else {
            revert BidWeak();
        }
    }
    
    
    function balance() public view returns(uint){
        return address(this).balance;
    }
    
    function recoverWeakBid() external {
        require( msg.sender != winner, "You are still the winner");
        uint bid_ = bids[msg.sender];
        bids[msg.sender] = 0;
        payable(msg.sender).transfer(bid_);
    }    
    
    function auctionEnded() external {
        require(block.timestamp > auctionEndTime, "The auction is not over");
        require(msg.sender == beneficiary, "Only beneficiary can claimer the bid");
        uint bid_ =bids[winner];
        bids[winner] = 0;
        payable(beneficiary).transfer(bid_);
    }
    
}

