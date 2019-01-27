pragma solidity ^0.5.1;

contract DAMP {

  address public admin;                     /* The address that has admin privileges */
  address payable public feeAccount;                /* The address that takes fees */
  uint public feeRate;                      /* The fee rate to charge */

  constructor (address admin_, address payable feeAccount_, uint feeRate_) public {
    admin = admin_;
    feeAccount = feeAccount_;
    feeRate = feeRate_;
  }

  mapping (address => Account) accounts;
  mapping (address => Manager) managers;

  address[] public availableTokens;
  mapping (address => bool) tokenAddressesInUse;

  address[] public availableExchanges;

  struct Account {
    address payable owner;        /* The owner of the account*/
    Manager manager;      /* Designated manager who can trade holdings */

    mapping (address => uint) holdings;       /* Holdings, addr 0 = ETH */
  }

  /* ========== Admin ========== */
  function setAdmin(address admin_) public {
    require(msg.sender == admin);
    admin = admin_;
  }

  function setFeeRate(uint feeRate_) public {
    require(msg.sender == admin);
    feeRate = feeRate_;
  }

  function setFeeAccount(address payable feeAccount_) public {
    require(msg.sender == admin);
    feeAccount = feeAccount_;
  }

  /* ========== Accounts ========== */

  /* Deposit into account */
  function deposit() public payable {
    Account storage acc = accounts[msg.sender];

    uint fee = msg.value * feeRate;
    acc.holdings[address(0)] = acc.holdings[address(0)] + (msg.value - fee);
    feeAccount.transfer(fee);

    /* Make the manager aware of deposit */
    if(acc.manager != Manager(0)){
      acc.manager.depositMade(msg.sender, msg.value);
    }
  }

  /*
    Withdraws from account, if sellHoldings == true, then all erc20 tokens are sold at market prices
    otherwise it will just withdraw any ethBal from Account.
  */
  function withdraw(uint amount) public {
    Account storage acc = accounts[msg.sender];

    require(amount > 0);
    require(amount <= acc.holdings[address(0)]);

    acc.holdings[address(0)] = acc.holdings[address(0)] - amount;
    msg.sender.transfer(amount);

    if(acc.manager != Manager(0)){
      acc.manager.withdrawalMade(msg.sender, amount, acc.holdings[address(0)]);
    }

  }

  /*
    Allows manager address to control the account holdings
      - Will overwrite previous manager.
  */
  function setAccountManager(address manager) public {
    require(managers[manager] != Manager(0));
    Manager mng = Manager(manager);
    accounts[msg.sender].manager = mng;
    mng.accountSubscribed(msg.sender);
  }

  /*
    Removes manager from accounjt
  */
  function removeAccountManager() public {
    require(accounts[msg.sender].manager != Manager(0));
    Manager manager = Manager(accounts[msg.sender].manager);
    accounts[msg.sender].manager = Manager(0);
    manager.accountUnsubscribed(msg.sender);
  }

  /* token address 0 is reserved for Ethereum itself */
  function getHoldings(address token, address user) public returns (uint bal) {
    return accounts[user].holdings[token];
  }

  function sellAllHoldings(address user) public {
    require(
      msg.sender == user
      || msg.sender == address(accounts[user].manager)
    );

    Account storage acc = accounts[user];

    /* The first exchange added should have large trading volumes */
    Exchange exchange = Exchange(availableExchanges[0]);

    /* Iterate through all available tokens and sell if any are held */
    for(uint i = 0; i < availableTokens.length; i++){
      uint bal = acc.holdings[availableTokens[i]];
      if(bal > 0){
        exchange.marketTrade(address(0), availableTokens[i], bal);
      }
    }

  }

  /* ========== Managers ========== */

  /* Let manager contracts to register with the platform*/
  function registerManager(address manager) public {
    managers[manager] = Manager(manager);
  }

  function unregisterManager() public {
    managers[msg.sender] = Manager(0);
  }

  /* ========== Exchanges ========== */

  function registerExchange(address exchangeAddress) public {
    require(msg.sender == admin);
    availableExchanges.push(exchangeAddress);
  }

  function unregisterExchange(address exchangeAddress) public {
    require(msg.sender == admin);

    bool exchangeIndexed = false;
    for(uint i = 0; i < availableExchanges.length - 1; i++){

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
  function trade(address user, address payable exchange,  address tokenGet, address tokenGive, uint amountGive) public {
    require(
      msg.sender == user
      || msg.sender == address(accounts[user].manager)
    );

    require(validateToken(tokenGet));
    require(validateToken(tokenGive));

    Account storage acc = accounts[user];

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

    if(tokenGive == address(0)){
      exchange.transfer(amountGive);
    }else{
      exch.depositToken(tokenGive, amountGive);
    }

    uint amountGet = exch.marketTrade(tokenGet, tokenGive, amountGive);

    if(tokenGet == address(0)){
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

  function validateToken(address token) public returns (bool valid) {
    /* ETH = 0 */
    if (token == address(0)){
      return true;
    }

    for(uint i = 0; i < availableTokens.length; i++){
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

    function balanceOf(address token, address user) public view returns (uint bal);

    function marketTrade(address tokenGet, address tokenGive, uint amountGive) public returns (uint amountGet);
}


/* Manager interface */
contract Manager {

  function depositMade(address account, uint depositAmount) public;
  function withdrawalMade(address account, uint withdrawalAmount, uint newBalance) public;

  function accountSubscribed(address account) public;
  function accountUnsubscribed(address account) public;

  function getFeeAddress() public returns (address);
  function getFeeRate() public returns (uint);
}
