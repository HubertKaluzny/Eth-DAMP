const express = require('express');
const Web3 = require('web3');

const simpleManagerAddress = '';
const simpleManagerInterface = require('./simpleManagerABI.js');

let w3 = new Web3('ws://localhost:8546');
let app = express();

app.set('view engine', 'ejs');

app.listen(3000);

app.get('/', (req, res) => {
  res.render('index');
});

let contract = new w3.eth.Contract(simpleManagerInterface, simpleManagerAddress);

contract.events.DepositEvent({}, (error, event) => {
  
});

contract.events.WithdrawalEvent({}, (error, event) => {

});

contract.events.SubscribeEvent({}, (error, event) => {

});

contract.events.UnSubscribeEvent({}, (error, event) => {

});
