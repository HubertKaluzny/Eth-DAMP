pragma solidity ^0.5.3;

contract DAMP {

  address public admin;                     /* The address that has admin privileges */
  address public fee_account;               /* The address that takes fees */
  uint public fee_rate;                     /* The fee rate to charge */

  function DAMP(address admin_,) {
    admin = admin_;
  }

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

  /* ========== Managers ========== */

  /* Let manager contracts to register with the platform*/
  function registerManager(address manager) public {
    require(msg.sender == admin);
    managers[manager] = Manager(manager);
  }

  function unregisterManager() public {
    require(msg.sender == admin);
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

    require()

  }

  function cancelOrder(address exchange, address tokenGet, uint amountGet, address tokenGive, uint amountGive, uint expires, uint nonce, uint8 v, bytes32 r, bytes32 s) public {
    require(exchanges[exchange] != 0);

  }

}

contract SafeMath {
  function safeMul(uint a, uint b) internal returns (uint) {
    uint c = a * b;
    assert(a == 0 || c / a == b);
    return c;
  }

  function safeSub(uint a, uint b) internal returns (uint) {
    assert(b <= a);
    return a - b;
  }

  function safeAdd(uint a, uint b) internal returns (uint) {
    uint c = a + b;
    assert(c>=a && c>=b);
    return c;
  }

  function assert(bool assertion) internal {
    if (!assertion) throw;
  }
}

/* Exchange Interface - From EtherDelta */
contract Exchange {

    function deposit() payable;
    function withdraw(uint amount);

    function depositToken(address token, uint amount);
    function withdrawToken(address token, uint amount);

    function balanceOf(address token, address user) constant returns (uint);

    function order(address tokenGet, uint amountGet, address tokenGive, uint amountGive, uint expires, uint nonce) public ();
    function cancelOrder(address tokenGet, uint amountGet, address tokenGive, uint amountGive, uint expires, uint nonce, uint8 v, bytes32 r, bytes32 s) public ();

}


/* Manager interface */
contract Manager {

  function depositMade(address account, uint depositAmount) public ();
  function withdrawalMade(address account, uint withdrawalAmount, bool sellAll, uint newBalance) public ();

  function getFeeAddress() public (returns address);
  function getFeeRate() public (returns uint);
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
