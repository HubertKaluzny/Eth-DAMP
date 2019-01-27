pragma solidity ^0.5.3;

contract DAMP {

  address public admin;                     /* The address that has admin privileges */
  address public fee_account;               /* The address that takes fees */
  uint public fee_rate;                     /* The fee rate to charge */

  function DAMP(address admin_, address fee_account_, uint fee_rate_) {
    admin = admin_;
    fee_account = fee_account_;
    fee_rate = fee_rate_;
  }

  mapping (address => Account) accounts;
  mapping (address => Manager) managers;

  address[] public availableTokens;
  mapping (address => bool) tokenAddressesInUse;

  address[] public availableExchanges;

  struct Account {
    address owner;        /* The owner of the account*/
    Manager manager;      /* Designated manager who can trade holdings */

    mapping (address => uint) holdings;       /* Holdings, addr 0 = ETH */
  }

  /* ========== Accounts ========== */

  /* Deposit into account */
  function deposit() public payable {
    Account acc = accounts[msg.sender];

    uint fee = msg.value * fee_rate;
    holdings[0] = holdings[0] + (msg.value - fee);
    admin.send(fee);

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
    Account acc = accounts[msg.sender];

    require(amount > 0);
    require(amount <= acc.holdings[0]);

    acc.holdings[0] = acc.holdings[0] - amount;
    msg.sender.send(amount);

    if(acc.manager != 0){
      acc.manager.withdrawalMade(msg.sender, amount, sellAll, acc.holdings[0]);
    }

  }

  /*
    Allows manager address to control the account holdings
      - Will overwrite previous manager.
  */
  function setAccountManager(address manager) public {
    require(managers[manager] != 0);
    Manager mng = Manager(manager);
    accounts[msg.sender].manager = mng;
    mng.accountSubscribed(msg.sender);
  }

  /*
    Removes manager from accounjt
  */
  function removeAccountManager() public {
    require(accounts[msg.sender].manager != 0);
    Manager manager = Manager(accounts[msg.sender].manager);
    accounts[msg.sender].manager = 0;
    manager.accountUnsubscribed(msg.sender);
  }

  /* token address 0 is reserved for Ethereum itself */
  function getHoldings(address token, address user) public returns (uint bal) {
    return accounts[user].holdings[token];
  }

  function sellAllHoldings(address user) public {
    require(
      sender.msg == user
      || sender.msg == accounts[user].manager)
    );

    Account acc = accounts[user];

    /* The first exchange added should have large trading volumes */
    Exchange exchange = Exchange(availableExchanges[0]);

    /* Iterate through all available tokens and sell if any are held */
    for(int i = 0; i < availableTokens; i++){
      uint bal = acc.holdings[availableTokens[i]];
      if(bal > 0){
        exchange.marketTrade(0, availableTokens[i], bal);
      }
    }

  }

  /* ========== Managers ========== */

  /* Let manager contracts to register with the platform*/
  function registerManager(address manager) public {
    managers[manager] = Manager(manager);
  }

  function unregisterManager() public {
    manager[msg.sender] = 0;
  }

  /* ========== Exchanges ========== */

  function registerExchange(address exchangeAddress) public {
    require(msg.sender == admin);
    availableExchanges.push(exchangeAddress);
  }

  function unregisterExchange(address exchangeAddress) public {
    require(msg.sender == admin);

    bool exchangeIndexed = false;
    for(int i = 0; i < availableExchanges - 1; i++){

      if(availableExchanges[i] == exchangeAddress){
        exchangeIndexed;
      }

      if(exchangeIndexed){
        availableExchanges[i] = availableExchanges[i + 1];
      }
    }

    delete availableExchanges[availableExchanges.length - 1];
  }

  /*
    Executes a trade on the specified exchange
      -> Verifies details
      -> Deposits holdings
      -> Executes trade on exchange
      -> Withdraws holdings
  */
  function trade(address user, address exchange,  address tokenGet, address tokenGive, uint amountGive){
    require(
      sender.msg == user
      || sender.msg == accounts[user].manager
    );

    require(validateToken(tokenGet));
    require(validateToken(tokenGive));

    Account acc = accounts[user];

    require(acc.holdings[tokenGive] > amountGive);

    bool validExchange = false;

    for(uint i = 0; i < availableExchanges.length; i++){
      if(availableExchanges[i] == exchange){
        validExchange = true;
        break;
      }
    }

    require(validExchange);

    Exchange exch = Exchange(exchange);

    acc.holdings[tokenGive] -= amountGive;

    if(tokenGive == 0){
      exch.deposit(amountGive);
    }else{
      exch.depositToken(tokenGive, amountGive);
    }

    uint amountGet = exch.marketTrade(tokenGet, tokenGive, amountGive);

    if(tokenGet == 0){
      exch.withdraw(amountGet);
    }else{
      exch.withdrawToken(tokenGet, amountGet);
    }

    acc.holdings[tokenGet] += amountGet;
  }

  /* ========== Tokens ========== */
  function addToken(address token) public {
    require(msg.sender == admin);
    availableTokens.push(token);
  }

  function removeToken(address token) public {
    require(msg.sender == admin);
    require(availableTokens.length > 0);

    if(availableTokens.length == 1){
      delete availableTokens[0];
    }

    uint index = -1;
    for(int i = 0; i < availableTokens.length - 1; i++){
      if(availableTokens[i] == token){
          index = i;
      }
    }

  }

  function validateToken(address token) public returns (bool valid) {
    /* ETH = 0 */
    if (token == 0){
      return true;
    }

    for(int i = 0; i < availableTokens.length; i++){
      if(availableTokens[i] == token){
        return true;
      }
    }

    return false;
  }

}

/* Exchange Interface - From EtherDelta */
contract Exchange {

    function deposit() payable public;
    function withdraw(uint amount) public;

    function depositToken(address token, uint amount) public;
    function withdrawToken(address token, uint amount) public;

    function balanceOf(address token, address user) constant returns (uint bal);

    function marketTrade(address tokenGet, address tokenGive, uint amountGive) public returns (uint amountGet);
}


/* Manager interface */
contract Manager {

  function depositMade(address account, uint depositAmount) public ();
  function withdrawalMade(address account, uint withdrawalAmount, bool sellAll, uint newBalance) public ();

  function accountSubscribed(address account);
  function accountUnsubscribed(address account);

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
    event Transfer(address indexed from, address indexed to, -uint tokens);
    event Approval(address indexed tokenOwner, address indexed spender, uint tokens);
}
