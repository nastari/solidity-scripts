pragma solidity ^0.8.4;

contract Token {
    mapping( address => uint ) _balanceOf;
    
    constructor(){
        _balanceOf[msg.sender] = 1000;
    }
    
    function transfer(address _to, uint _amount) public returns(bool){
        require(_balanceOf[msg.sender] >= _amount,"Doesnt have money enough");
        _balanceOf[msg.sender] -= _amount;
        _balanceOf[_to] += _amount;
        return true;
    }
    
    function balanceOf(address _address) public view returns(uint){
        return _balanceOf[_address];
    } 
}

contract Stream {
    
    Token token;
    using Address for address;
    uint private _balanceAirDrop;
    
    constructor( Token _addr){
        token = _addr;        
    }
    mapping( address => Situation ) public airdrop_given;
    
    struct Situation {
        bool initialized;
        uint next_receive;
    }
    
    function balanceAirDrop() public view returns(uint){
        return token.balanceOf(address(this));
    }
    
    
    modifier isNotContract {
        bool iam = msg.sender.isContract();
        require(!iam, "Nice try, only humans please!");
        _;
    }
    
    function airdropGiven() public isNotContract returns(bool){

        Situation storage situation = airdrop_given[msg.sender];
        
        if(situation.initialized){
            require(situation.next_receive < block.timestamp, "You need wait.");
        } else {
            situation.initialized = true;
        }
        
        situation.next_receive = block.timestamp + 300;

        token.transfer(msg.sender,50);
        
        return true;
    }
    
}


library Address {
    function isContract(address account) internal view returns (bool) {
        bytes32 codehash;
        bytes32 accountHash = 0xc5d2460186f7233c927e7db2dcc703c0e500b653ca82273b7bfad8045d85a470;
        assembly { codehash := extcodehash(account) }
        return (codehash != accountHash && codehash != 0x0);
    }
    
}