pragma solidity ^0.5.1;

/* Manager interface */
contract Manager {

  function depositMade(address account, uint depositAmount) public;
  function withdrawalMade(address account, uint withdrawalAmount, uint newBalance) public;

  function accountSubscribed(address account) public;
  function accountUnsubscribed(address account) public;

  function getFeeAddress() public returns (address);
  function getFeeRate() public returns (uint);
}

/*
  Emit events to web3js, and pass trading instructions to DAMP
*/
contract SimpleManager is Manager {

  address public admin;
  address public feeAccount;
  uint public feeRate;

  DAMP public damp;

  constructor (address admin_, address feeAccount_, uint feeRate_, address damp_address) public {
    admin = admin_;
    feeAccount = feeAccount_;
    feeRate = feeRate_;

    damp = DAMP(damp_address);
    damp.registerManager(address(this));
  }

  event DepositEvent(
    address indexed _account,
    uint _value
  );

  event WithdrawalEvent(
    address indexed _account,
    uint _value,
    uint _newBalance
  );

  event SubscribeEvent(
    address indexed _account
  );

  event UnSubscribeEvent(
    address indexed _account
  );

  function depositMade(address account, uint depositAmount) public {
    emit DepositEvent(account, depositAmount);
  }


  function withdrawalMade(address account, uint withdrawalAmount, uint newBalance) public {
    emit WithdrawalEvent(account, withdrawalAmount, newBalance);
  }

  function accountSubscribed(address account) public {
    emit SubscribeEvent(account);
  }

  function accountUnsubscribed(address account) public {
    emit SubscribeEvent(account);
  }
}

/* DAMP interface */
contract DAMP {

  function registerManager(address manager) public;
  function unregisterManager() public;

  function trade(address user, address payable exchange,  address tokenGet, address tokenGive, uint amountGive) public;

}
