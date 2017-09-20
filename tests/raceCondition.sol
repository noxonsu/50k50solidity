pragma solidity ^ 0.4.16;

//https://youtu.be/e3KKdbRr434 

contract NoxonInterface {
	function changeOwner(address _newOwner);
	function acceptOwnership();
	function changeManager(address _newManager);
	function acceptManagership();
	function Noxon();
	function NoxonInit() payable returns (bool);
	function lockEmission();
	function unlockEmission();
	function totalSupply() constant returns(uint256);
	function burnPrice() constant returns(uint256);
	function emissionPrice() constant returns(uint256);
	function balanceOf(address _owner) constant returns(uint256 balance);
	function transfer(address _to, uint256 _amount) returns(bool success);
	function burnTokens(uint256 _amount) private returns(bool success);
	event TokenBought(address indexed buyer, uint256 ethers, uint _emissionedPrice, uint amountOfTokens);
	event TokenBurned(address indexed buyer, uint256 ethers, uint _burnedPrice, uint amountOfTokens);
	function getBurnPrice() returns(uint);
	event EtherReserved(uint etherReserved);
	function addToReserve() payable returns(bool);
	function burnAll() external returns(bool);
}

contract InitTesters {
    NoxonInterface main;
    Test tester1;
    Test tester2;
    Test tester3;
    address targetContract = 0xCdf3C55778A959C018113134a6D7D7A7B56786dC;  
    
    function InitTesters() payable {
      tester1 = new Test(targetContract);
      tester1.call.value(1000)();
      tester2 = new Test(targetContract);
      tester2.call.value(1000)();
    }
    
    function () {
        tester1.process();
        tester2.process();
    }
    
}

contract Test {
    NoxonInterface main;
    
    function Test(address targetContract) payable {
       main = NoxonInterface(targetContract);
    }
    
    
    
    function () payable {
       
    }
    
    function process() {
       main.call.value(26)();
       main.call.value(260)();
       main.transfer(address(main),2);
       main.addToReserve.value(10);
       main.addToReserve.value(100);
       main.transfer(address(main),2);
    }
    
}

 
