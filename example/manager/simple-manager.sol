/* Manager interface */
contract Manager {

  function depositMade(address account, uint depositAmount) public ();
  function withdrawalMade(address account, uint withdrawalAmount, bool sellAll, uint newBalance) public ();

}

/*
  Emit events to web3js, and pass trading instructions to DAMP
*/
contract SimpleManager is Manager {

  event DepositEvent(
    address indexed _account,
    uint _value
  );

  event WithdrawalEvent(
    address indexed _account,
    uint _value,
    bool _sellAll,
    uint _newBalance
  );


  function depositMade(address account, uint depositAmount) public {
    emit DepositEvent(account, depositAmount);
  }


  function withdrawalMade(address account, uint withdrawalAmount, bool sellAll, uint newBalance) public {
    emit WithdrawalEvent(account, withdrawalAmount, sellAll, newBalance);
  }


}
