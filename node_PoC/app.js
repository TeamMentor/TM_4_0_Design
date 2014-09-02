/*
 * Module dependencies
 */
var express = require('express');

var app = express();

app.set('view engine', 'jade')

var sourceDir = '../../source';

app.get('/'                ,function (req, res)               { res.redirect('/default.html');   });

app.get('/:page.html',function (req, res)                     { res.render(sourceDir + '/html/'+ req.params.page                      + '.jade');}); 
app.get('/:area/:page.html',function (req, res)               { res.render(sourceDir + '/html/'+ req.params.area +'/'+req.params.page + '.jade');}); 

app.get('/deploy/html/:area/:page.html',function (req, res)   { res.redirect('/' + req.params.area +'/'+req.params.page + '.html');}); 

app.use(express.static(__dirname + '/..'));

app.listen(3001)

console.log("Starting 'TM Jade' Poc on port 3001"); 