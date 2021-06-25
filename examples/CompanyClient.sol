pragma solidity ^0.8.4;

// Did you notice any bug ? Make a Pull Request!
contract Company {
    
    address public administration;
    mapping( address => Client ) public clients;
    
    event Connected( address client );
    event Disconnected( address client );
    
    constructor(){
        administration = msg.sender;
    }
    
    receive () payable external {}
    
    function balance() external view returns( uint ){
        return address(this).balance;
    }
    
    modifier isAdmin {
        require(msg.sender == administration, "Not allowed to you");
        _;
    }
    
    function register() external {
        Client client = new Client(msg.sender);
        clients[msg.sender] = client;    
        emit Connected(msg.sender);
    }
    
    function break_services( address client_ ) public isAdmin {
        Client client = clients[client_];
        client.disconnect();
    }
    
    function maintain_services( address client_ ) public isAdmin {
        Client client = clients[client_];
        client.connect();
    }

    
    function disconnected(address client_) external {
        require(msg.sender == address(clients[client_]), "Not allowed to you");
        emit Disconnected(client_);
    }
    
    
    function withdraw() public isAdmin {
        ( bool success,) = payable(administration).call{value: address(this).balance }("");
        require(success == true, "Transfer Failed.");
    }
}


contract Client {
    
    address public owner;
    address public company;
    Company public contract_parent_instance_on_blockchain;
    
    bool public connection;
    
    uint public time_to_use;
    
    uint constant rounds = 360;
    
    constructor( address client_ ) {
        connection = true;
        time_to_use = block.timestamp + rounds;
        owner = client_;
        company = msg.sender;
        contract_parent_instance_on_blockchain = Company(payable(msg.sender));
    }
    
    function disconnect() public {
        require(msg.sender == company || msg.sender == owner, "Not allowed to you.");
        require(connection == true, "You already disconnected.");
        if(msg.sender == owner ){
            contract_parent_instance_on_blockchain.disconnected(owner);
        }
        connection = false;
    }
    
    function connect() payable public {
        require(msg.sender == company  || msg.sender == owner, "Not allowed to you.");
        require(connection == false, "You already connected.");
        if(msg.sender == owner){
            require( msg.value >= 7 ether, "You need pay at least 7 Ether for the service.");
        }
        time_to_use = block.timestamp + rounds;
        connection = true;
        
        (bool success,) = payable(company).call{ value: msg.value }("");
        require(success == true, "Transfer failed.");
    }
    
    
    function service() public returns(bool){
        require(msg.sender == company  || msg.sender == owner, "Not allowed to you.");
        if(block.timestamp > time_to_use){
            disconnect();
        }
        return connection;
    }
    
} 