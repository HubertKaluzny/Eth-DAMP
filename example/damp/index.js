const express = require('express');
const Web3 = require('web3');

const simpleDAMPAddress = '0x31fcaf0b09ed4f49b2748c6e6d5ec3921cd96571';
const simpleDAMP = require('./ethDAMPABI.js');

let web3 = new Web3(
  // Replace YOUR-PROJECT-ID with a Project ID from your Infura Dashboard
  new Web3.providers.WebsocketProvider("wss://ropsten.infura.io/ws/v3/c65c07aeb8dd4f9ca18dc94194ac3010")
);

let app = express();

let users = [];
let managers = [];
let exchanges = [];

app.set('view engine', 'ejs');

app.get('/', (req, res) => {
  res.render('index', {users: users, exchanges: exchanges, managers: managers});
});

let contract = new web3.eth.Contract(simpleDAMP, simpleDAMPAddress);

contract.events.allEvents({}, (error, event) => {
  console.log("event! = " + JSON.stringify(event));
  if(event.event == "UserRegistration"){
    users.push(event.returnValues._account);
  }else if(event.event == "ExchangeRegistration"){;
    exchanges.push(event.returnValues._exchange_address);
  }else if(event.event == "ManagerRegistration"){
    managers.push(event.returnValues._manager_address);
  }
});

console.log("application listening on port 3000");

app.listen(3001);
