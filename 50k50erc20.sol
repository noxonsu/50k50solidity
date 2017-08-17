pragma solidity ^0.4.15;

// ERC Token Standard #20 Interface
// https://github.com/ethereum/EIPs/issues/20
contract ERC20Interface {
     function totalSupply() constant returns (uint256 totalSupplyReturn);
     function balanceOf(address _owner) constant returns (uint256 balance);
     function transfer(address _to, uint256 _value) returns (bool success);
     function transferFrom(address _from, address _to, uint256 _value) returns (bool success);
     function approve(address _spender, uint256 _value) returns (bool success);
     function allowance(address _owner, address _spender) constant returns (uint256 remaining);
     event Transfer(address indexed _from, address indexed _to, uint256 _value);
     event Approval(address indexed _owner, address indexed _spender, uint256 _value);
 }
 

  
 contract Noxon is ERC20Interface {
     string public constant symbol = "NOX";
     string public constant name = "noxon.fund";
     uint8 public constant decimals = 18;
     uint256 _totalSupply = 0;
     uint256 _sellPrice;
     uint256 _buyPrice;
     bool public salelocked = false;
     // Owner of this contract
     address public owner;
  
     // Balances for each account
     mapping(address => uint256) balances;
  
     // Owner of account approves the transfer of an amount to another account
     mapping(address => mapping (address => uint256)) allowed;
  
     // Functions with this modifier can only be executed by the owner
     modifier onlyOwner() {
         require(msg.sender != owner);
         _;
     }
     
     address newOwner;

     // BK Ok - Only owner can assign new proposed owner
     function changeOwner(address _newOwner) onlyOwner {
        newOwner = _newOwner;
     }

     // BK Ok - Only new proposed owner can accept ownership 
     function acceptOwnership() {
        if (msg.sender == newOwner) {
            owner = newOwner;
        }
     }
     
    modifier onlyPayloadSize(uint numwords) {
    assert(msg.data.length == numwords * 32 + 4);
        _;
    }
    
     // Constructor
     function Noxon() payable {
         
         require(_totalSupply == 0);
         require(msg.value > 0);
         owner = msg.sender;
         balances[owner] = 1e18;//owner got 1 token
         _totalSupply = balances[owner];
         _sellPrice = msg.value;
         _buyPrice = _sellPrice*2;
     }
     
     //The owner can turn off accepting new ether
     function lockSale() onlyOwner {
        salelocked = true;
     } 
     
     function unlockSale() onlyOwner {
        salelocked = false;
     } 
  
     function totalSupply() constant returns (uint256) {
         return _totalSupply;
     }
     
     function sellPrice() constant returns (uint256) {
         return _sellPrice;
     }
     
     function buyPrice() constant returns (uint256) {
         return _buyPrice;
     }
  
     // What is the balance of a particular account?
     function balanceOf(address _owner) constant returns (uint256 balance) {
         return balances[_owner];
     }
  
     // Transfer the balance from owner's account to another account
     function transfer(address _to, uint256 _amount) onlyPayloadSize(2) returns (bool success)  {
         
         // if you send TOKENS to the contract they will be sold
         if (_to == address(this)) return sellToContact(_to,_amount);
         
         if (balances[msg.sender] >= _amount 
             && _amount > 0
             && balances[_to] + _amount > balances[_to]) {
             balances[msg.sender] -= _amount;
             balances[_to] += _amount;
             Transfer(msg.sender, _to, _amount);
             
             
             
             return true;
         } else {
             return false;
         }
     }
    
    function sellToContact(address _to,uint256 _amount) onlyPayloadSize(2) internal returns (bool success) {
        uint256 _sellPriceTmp = _sellPrice;
        if (balances[msg.sender] >= _amount 
             && _amount > 0 && _to == address(this)) {
            
             Transfer(msg.sender, 0, _amount);
             balances[msg.sender] -= _amount;                                   // subtracts the amount from seller's balance
             
             _totalSupply -= _amount;
             
             msg.sender.transfer(_amount * _sellPrice/1e18);              // sends ether to the seller
             
             _sellPrice = getSellPrice();
             require(_sellPriceTmp == _sellPrice);
             
             return true;
         } else {
             return false;
         }
    }
    
    function () payable {
        //buy tokens
        
        //save tmp for double check in the end of function
        //sellPrice never changes when someone buy tokens
        uint256 _sellPriceTmp = _sellPrice; 
        
        require(salelocked == false);
        require(_sellPrice>0 && _buyPrice > _sellPrice);
        require(msg.value>0);

        // calculate the amount
        uint256 amount = msg.value*1e18/_buyPrice;                
        
        //check overflow
        require(balances[msg.sender] + amount > balances[msg.sender]);
        
        // adds the amount to buyer's balance
        balances[msg.sender] += amount;                   
       
        _totalSupply += amount;
        owner.transfer(msg.value/2);    //send 50% to owner
        Transfer(0, msg.sender, amount);
        
        //are prices unchanged?   
        _sellPrice = getSellPrice();   
        require(_sellPrice == _sellPriceTmp);  

   }
   function getSellPrice() returns (uint) {
       return this.balance*1e18/_totalSupply;
   }
   
   
   //add Ether to reserve fund without issue new tokens (prices will growth)
    function addToReserve() payable returns (bool) {
        if (msg.value > 0) {
            _sellPrice = getSellPrice();
            _buyPrice = _sellPrice*2;
            return true;
        } else {
            return false;
        }
    }
     
      // Send _value amount of tokens from address _from to address _to
     // The transferFrom method is used for a withdraw workflow, allowing contracts to send
     // tokens on your behalf, for example to "deposit" to a contract address and/or to charge
     // fees in sub-currencies; the command should fail unless the _from account has
     // deliberately authorized the sender of the message via some mechanism; we propose
     // these standardized APIs for approval:
     function transferFrom(
         address _from,
         address _to,
         uint256 _amount
     ) onlyPayloadSize(3) returns (bool success) {
         if (balances[_from] >= _amount
             && allowed[_from][msg.sender] >= _amount
             && _amount > 0
             && balances[_to] + _amount > balances[_to]) {
             balances[_from] -= _amount;
             allowed[_from][msg.sender] -= _amount;
             balances[_to] += _amount;
             Transfer(_from, _to, _amount);
             return true;
         } else {
             return false;
         }
     }
  
     // Allow _spender to withdraw from your account, multiple times, up to the _value amount.
     // If this function is called again it overwrites the current allowance with _value.
     function approve(address _spender, uint256 _amount) onlyPayloadSize(2) returns (bool success) {
         allowed[msg.sender][_spender] = _amount;
         Approval(msg.sender, _spender, _amount);
         return true;
     }
  
     function allowance(address _owner, address _spender) constant returns (uint256 remaining) {
         return allowed[_owner][_spender];
     }
     
     
 }
