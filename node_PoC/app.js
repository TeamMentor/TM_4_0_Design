/*
 * Module dependencies
 */
var express = require('express');

var app = express();

app.set('view engine', 'jade')

var sourceDir = '../../source';  

//special redirect

app.get('/getting-started/index.html', function (req, res)  { res.redirect('/user/returning-user-login.html')});

//Redirect to Jade pages
app.get('/'                            ,function (req, res)  { res.redirect('/default.html'                                                     );});
app.get('/deploy/html/:area/:page.html',function (req, res)  { res.redirect('/'                 + req.params.area +'/'+req.params.page + '.html');}); 

//Render Jade pages
app.get('/:page.html'                  ,function (req, res)  { res.render  (sourceDir + '/html/'+ req.params.page                      + '.jade');}); 
app.get('/:area/:page.html'            ,function (req, res)  { res.render  (sourceDir + '/html/'+ req.params.area +'/'+req.params.page + '.jade');}); 

//Post data
app.post('/action/login'               ,function (req, res)  
        { 
            res.redirect('/user/returning-user-validation.html');
            
            //res.redirect('/user/returning-user-forgot-password.html');
        });




app.use(express.static(__dirname + '/..'));

app.listen(3001)

console.log("Starting 'TM Jade' Poc on port 3001"); 