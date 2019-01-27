module.exports = [
	{
		"constant": false,
		"inputs": [
			{
				"name": "manager",
				"type": "address"
			}
		],
		"name": "registerManager",
		"outputs": [],
		"payable": false,
		"stateMutability": "nonpayable",
		"type": "function"
	},
	{
		"constant": false,
		"inputs": [],
		"name": "unregisterManager",
		"outputs": [],
		"payable": false,
		"stateMutability": "nonpayable",
		"type": "function"
	},
	{
		"constant": false,
		"inputs": [
			{
				"name": "user",
				"type": "address"
			},
			{
				"name": "exchange",
				"type": "address"
			},
			{
				"name": "tokenGet",
				"type": "address"
			},
			{
				"name": "tokenGive",
				"type": "address"
			},
			{
				"name": "amountGive",
				"type": "uint256"
			}
		],
		"name": "trade",
		"outputs": [],
		"payable": false,
		"stateMutability": "nonpayable",
		"type": "function"
	}
];
