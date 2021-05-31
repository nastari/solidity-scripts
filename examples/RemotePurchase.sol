pragma solidity ^0.8.4;

contract RemotePurchase {
    
    uint public value;
    address private seller;
    address private buyer;
    
    enum State { Created, Locked, Release, Inactive }
    
    State public state;
    
    
    error OnlyBuyer();
    error OnlySeller();
    error InvalidState();
    error ValueNotEven();


    event Aborted();
    event itemReceived();
    event  SellerRefunded();

    event PurchaseConfirmed();
    
    modifier onlyBuyer(){
        if(msg.sender != buyer){
            revert OnlyBuyer();
        }
        _;
    }
    
        
    modifier onlySeller(){
        if(msg.sender != seller){
            revert OnlySeller();
        }
        _;
    }
    
    modifier condition(bool _condition) {
        require(_condition);
        _;
    }

    
    

    constructor() payable {
        

        seller = payable(msg.sender);

        
        value = msg.value / 2;
        if( ( 2 * value ) != msg.value){
            revert ValueNotEven();
        }
    
        
    }
    
    
    function balanceContract() public view returns(uint){
        return address(this).balance;
    }
    

    
        modifier inState(State _state) {
        if (state != _state)
            revert InvalidState();
        _;
    }
    

    
    
    function abort() public onlySeller inState(State.Created) {
        emit Aborted();

        payable(seller).transfer(address(this).balance);

        state = State.Inactive;
    }
    
    function confirmPurchase() public inState(State.Created) condition((value * 2) == msg.value) payable {
        
       
        emit PurchaseConfirmed();
        

        
        buyer = payable(msg.sender);
    
        state = State.Locked;
    }
    
  
    
    function confirmReceived() public onlyBuyer() inState(State.Locked) {
        emit itemReceived();
        
        payable(buyer).transfer(value);
        
        state = State.Release;
    }

        function refundSeller()
        public
        onlySeller
        inState(State.Release)
    {
        emit SellerRefunded();
        // It is important to change the state first because
        // otherwise, the contracts called using `send` below
        // can call in again here.
        state = State.Inactive;

        payable(seller).transfer(3 * value);
    }
    
    
    
    
    
}