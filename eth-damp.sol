pragma solidity ^0.5.3;

contract DAMP {

  mapping (address => Account) public accounts;
  mapping (address => Manager) public managers;

  struct Account {
    address owner;        /* The owner of the account*/
    Manager manager;      /* Designated manager who can trade holdings */

    uint weiBal; /* Ethereum holdings */

    mapping (address => uint) holdings; /* Maps ERC20 tokens to balances */
  }

  /* Deposit into account */
  function deposit() public payable {
      Account acc = accounts[msg.sender];
      acc.weiBal += msg.value;

      /* Make the manager aware of deposit */
      if(acc.manager != 0){
        acc.manager.depositMade(msg.sender, msg.value);
      }


  }

  function setAccountManager(address manager) public {

    /* Only registered managers can be delegated*/
    require(managers[manager] != 0);

  }

  function removeAccountManager() public {
    accounts[msg.sender].manager = 0;
  }

  /*
    Withdraws from account, if sellHoldings == true, then all erc20 tokens are sold at market prices
    otherwise it will just withdraw any ethBal from Account.
  */
  function withdraw(bool sellHoldings) public {

  }

  /* Let manager contracts to register with the platform*/
  function registerManager() public {
    managers[msg.sender] = Manager(msg.sender);
  }

}

/* Manager interface */
contract Manager {

  function depositMade(address account, uint depositAmount) public ();
  function withdrawalMade(address account, uint withdrawalAmount, bool sellAll, uint newBalance) public ();

}

/* Interface with ERC20 tokens */
contract ERC20 {
    function totalSupply() public constant returns (uint);
    function balanceOf(address tokenOwner) public constant returns (uint balance);
    function allowance(address tokenOwner, address spender) public constant returns (uint remaining);
    function transfer(address to, uint tokens) public returns (bool success);
    function approve(address spender, uint tokens) public returns (bool success);
    function transferFrom(address from, address to, uint tokens) public returns (bool success);
    event Transfer(address indexed from, address indexed to, uint tokens);
    event Approval(address indexed tokenOwner, address indexed spender, uint tokens);
}
