pragma solidity ^0.5.3;

contract DAMP {

  mapping (address => Account) accounts;
  mapping (address => Manager) managers;
  mapping (address => Exchange) exchanges;

  struct Account {
    address owner;        /* The owner of the account*/
    Manager manager;      /* Designated manager who can trade holdings */

    uint bal; /* Ethereum holdings */

    mapping (address => uint) holdings; /* Maps ERC20 tokens to balances */
  }

  /* ========== Accounts ========== */

  /* Deposit into account */
  function deposit() public payable {
      Account acc = accounts[msg.sender];
      acc.bal += msg.value;

      /* Make the manager aware of deposit */
      if(acc.manager != 0){
        acc.manager.depositMade(msg.sender, msg.value);
      }
  }

  /*
    Withdraws from account, if sellHoldings == true, then all erc20 tokens are sold at market prices
    otherwise it will just withdraw any ethBal from Account.
  */
  function withdraw(uint amount) public {
    require(accounts[msg.sender].bal)
  }

  function sellAllHoldings() public {

  }

  /* ========== Managers ========== */

  /* Let manager contracts to register with the platform*/
  function registerManager() public {
    managers[msg.sender] = Manager(msg.sender);
  }

  function unregisterManager() public {
    manager[msg.sender] = 0;
  }

  function setAccountManager(address manager) public {
    /* Only registered managers can be delegated*/
    require(managers[manager] != 0);

    accounts[msg.sender].manager = manager[manager];
  }

  function removeManager() public {
    accounts[msg.sender].manager = 0;
  }

  /* ========== Exchanges ========== */

  function registerExchange() public {
    exchanges[msg.sender] = Exchange(msg.sender);
  }

  function unregisterExchange() public {
    exchanges[msg.sender] = 0;
  }

  function order(address exchange, address tokenGet, uint amountGet, address tokenGive, uint amountGive, uint expires, uint nonce) public {
    require(exchanges[exchange] != 0);

  }

  function cancelOrder(address exchange, address tokenGet, uint amountGet, address tokenGive, uint amountGive, uint expires, uint nonce, uint8 v, bytes32 r, bytes32 s) public {
    require(exchanges[exchange] != 0);

  }

}

/* Exchange Interface - From EtherDelta */
contract Exchange {

    function order(address tokenGet, uint amountGet, address tokenGive, uint amountGive, uint expires, uint nonce) public ();
    function cancelOrder(address tokenGet, uint amountGet, address tokenGive, uint amountGive, uint expires, uint nonce, uint8 v, bytes32 r, bytes32 s) public ();

}


/* Manager interface */
contract Manager {

  function depositMade(address account, uint depositAmount) public ();
  function withdrawalMade(address account, uint withdrawalAmount, bool sellAll, uint newBalance) public ();

}

/* ERC20 Token Interface */
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
