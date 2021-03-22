pragma solidity 0.5.10;

contract Admin {
    address admin = msg.sender;

    function isAdmin() internal view returns (bool) {
        return msg.sender == admin;
    }
}

// Developer Comments
// Support adding extra admins.
contract MultiAdmin is Admin {
    mapping(address => bool) extraAdmins;

    function addAdmin(address who) external {
        require(isAdmin());
        extraAdmins[who] = true;
    }
    function isAdmin() internal view returns (bool) {
        return extraAdmins[msg.sender] || super.isAdmin();
    }
}

// Developer Comments
// Support permanently disabling admin functionality.
contract TempAdmin is Admin {
    bool administratable = true;
    function disableAdmin() external {
        require(isAdmin());
        administratable = false;
    }

    /* AUDIT /*
      The method has already been called within the inherited inheritance, 
      possibility of behavior problems, BUGS and anomalies
      SEVERITY: WARNING
    */////////*
    function isAdmin() internal view returns (bool) {
        return administratable && super.isAdmin();
    }
}



/* AUDIT /*
// Multiple Inheritance  - C3 linearization Analysis
// the code is executed in this order:
// kill → MultiAdmin.isAdmin → TempAdmin.isAdmin → Admin.isAdmin
// SEVERITY: WARNING
/*//////*/
contract Bank is TempAdmin, MultiAdmin {
    mapping(address => uint256) public balanceOf;

    function deposit() external payable {
        if (administratable) {
            require(isAdmin(), "Admins only during testing.");
        }
        balanceOf[msg.sender] += msg.value;
    }

    function withdraw() external {
        uint256 amount = balanceOf[msg.sender];
        balanceOf[msg.sender] = 0;
        msg.sender.transfer(amount);
    }


    function kill() external {
        /*  AUDIT /*
        Which contract's of that function is executed?
        This is a bad order, leading to checking the equivalent of this:
        extraAdmin[msg.sender] || (administratable && msg.sender == admin)
        but state  extraAdmin[msg.sender], does not change for no more administrators
        Non admins can acess that method
        SEVERITY: CRITICAL
        ***BUG FOUND***
        *//////////*
        require(isAdmin());
        selfdestruct(msg.sender);
    }
}