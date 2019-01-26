pragma solidity ^0.5.3;

contract DAMP {

  mapping (address => Account) public accounts;

  struct Manager {
    address manager;
  }

  struct Account {
    address owner;        /* The owner of the account*/
    Manager manager;      /* Designated manager who can trade holdings */

    uint ethBal; /* Ethereum holdings */
    mapping (address => uint) holdings; /* Maps ERC20 tokens to balances */
  }

  function openAccount()

  /* Deposit into account */
  function deposit() public payable {

  }

  /*
    Withdraws from account, if sellHoldings == true, then all erc20 tokens are sold at market prices
    otherwise it will just withdraw any ethBal from Account.
  */
  function withdraw(bool sellHoldings) public {

  }

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
