const express = require('express');
const Web3 = require('web3');

const simpleManagerAddress = '0x8908f7b7c736ed5231cc112073d22a086d3bce3d';
const simpleManagerInterface = require('./simpleManagerABI.js');

let web3 = new Web3(
  // Replace YOUR-PROJECT-ID with a Project ID from your Infura Dashboard
  new Web3.providers.WebsocketProvider("wss://ropsten.infura.io/ws/v3/c65c07aeb8dd4f9ca18dc94194ac3010")
);

let app = express();

var users = new Map();

app.set('view engine', 'ejs');

app.get('/', (req, res) => {
  res.render('index', {users: users});
});

let contract = new web3.eth.Contract(simpleManagerInterface, simpleManagerAddress);

contract.events.allEvents({}, (error, event) => {
  console.log("event! = " + JSON.stringify(event));
  if(event.event == "DepositEvent"){
    let bal = users.get(event.returnValues._account);
    bal += event.returnValues._value;
    users.set(event.returnValues._account, bal);

  }else if(event.event == "WithdrawalEvent"){;
    users.set(event.returnValues._account, event.returnValues._newBalance);

  }else if(event.event == "SubscribeEvent"){
    if(event.returnValues._balance == null){
      event.returnValues._balance = 0;
    }
    users.set(event.returnValues._account, event.returnValues._balance);

  }else if(event.event == "UnSubscribeEvent"){
    users.delete(event.returnValues._account);

  }
});

console.log("application listening on port 3000");

app.listen(3000);
