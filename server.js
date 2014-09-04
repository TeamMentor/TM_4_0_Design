var http = require('http')
var port = process.env.PORT || 1337;

var express = require('express');

var app = express();

app.get('/', function(req, res) { res.send("Using Express") });

app.listen(port)

console.log("Starting 'TM Jade' Poc on port " + port); 
