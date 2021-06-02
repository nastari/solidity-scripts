// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.4;

// Did you notice any bugs? make a Pull Request

// Proposal for Improvements BlindAuction
contract BlindAuctionImprovement {

  mapping( address => uint[] ) public bids;
  mapping( address => bytes32 ) choice;
  
  address public beneficiary;
  
  uint public highest_bid;
  address highest_bidder;
  
  uint public limit_time_to_bid;
  uint public limit_time_to_refund;
  
  mapping( address => uint ) public funds_not_yet_recovered;
  bool public ended = false;
  
  constructor( address _beneficiary ) {
      beneficiary = _beneficiary;
      limit_time_to_bid = block.timestamp + 1500000;
      limit_time_to_refund = limit_time_to_bid + 1500000;
  }
  
  function balance() public view returns(uint){
      return address(this).balance;
  }

  function bid() payable public {
    require( block.timestamp < limit_time_to_bid, "Auction is over");
    bids[msg.sender].push(msg.value);
  }
  

  function helper_create_mistery_bytes(uint index, string memory secret ) pure public returns(bytes32){
      return keccak256(abi.encodePacked( index , secret ));
  }
  
   
   
//  bytes32 _index_mistery = keccak256(abi.encodePacked( index, secret )) 
  function choice_bid( bytes32 _index_mistery ) public {
    require( block.timestamp < limit_time_to_bid, "Auction is over");
      choice[msg.sender] = _index_mistery;
  } 
  
  
   function reveal( uint index_, string memory secret_ ) public {
      require( block.timestamp > limit_time_to_bid, "Auction is not over");
      require( block.timestamp < limit_time_to_refund, "Reveal is over");
      require(choice[msg.sender] == keccak256(abi.encodePacked( index_ , secret_ )), "Wrong credentials");
    
      uint refund = 0;
      for( uint i = 0 ; i < bids[msg.sender].length ; i++ ){
          if(i != index_) {
              refund += bids[msg.sender][i];
          } else {
              if(!is_winner( msg.sender, bids[msg.sender][i])){
                  refund += bids[msg.sender][i];
              }
          }
      }
      
      choice[msg.sender] = bytes32(0);
      payable(msg.sender).transfer(refund);
   }
   
   
   function is_winner( address bidder, uint value ) internal returns(bool){
      
       if( value > highest_bid ){
            funds_not_yet_recovered[highest_bidder] = highest_bid;   
            highest_bidder = bidder;
            highest_bid = value;
            return true;
       }
       
       return false;
   }
   
    function withdraw() public {
       uint funds = funds_not_yet_recovered[msg.sender];
        funds_not_yet_recovered[msg.sender] = 0;
        payable(msg.sender).transfer(funds);
   }
   
   function gain() public {
       require(msg.sender == beneficiary, "Wrong credentials");
       require( block.timestamp > limit_time_to_refund, "Revelation is not over");
       require( ended == false, "Auction already ended");
       
       ended = true;
       payable(msg.sender).transfer(address(this).balance);
   }
   

}












