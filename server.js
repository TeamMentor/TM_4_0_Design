var http = require('http')
var port = process.env.PORT || 1337;

var express = require('express');

var app = express();

require('./node_tm/routes.js')(app);

app.use(express.static(__dirname)); 

app.listen(port)

console.log("Starting 'TM Jade' Poc on port " + port); 
