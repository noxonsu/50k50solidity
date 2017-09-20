contract TestProcess {
    Noxon main;
    
    function TestProcess() payable {
        main = new Noxon();
    }
   
    function () payable {
        
    }
     
    function init() returns (uint) {
       
        if (!main.NoxonInit.value(12)()) throw;    //init and set burn price as 12 and emission price to 24 
        if (!main.call.value(24)()) revert(); //buy 1 token
 
        assert(main.balanceOf(address(this)) == 2); 
        
        if (main.call.value(23)()) revert(); //send small amount (must be twhrowed)
        assert(main.balanceOf(address(this)) == 2); 
    }
    
    
    
    function test3() returns (uint) {
        if (!main.call.value(26)()) revert(); //check floor round (26/24 must issue 1 token)
        assert(main.balanceOf(address(this)) == 3); 
        assert(main.emissionPrice() == 24); //24.6 but round floor
        return main.balance;
    }
    
    function test33() returns (uint){
        if (!main.call.value(40)()) revert(); //check floor round (40/24 must issue 1 token)
        assert(main.balanceOf(address(this)) == 4); 
        //assert(main.emissionPrice() == 28);
        //return main.burnPrice();
    } 
    
    function test4() {
        if (!main.transfer(address(main),2)) revert();
        assert(main.burnPrice() == 14);
    } 
    
}
