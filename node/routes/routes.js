/*jslint node: true */
"use strict";

module.exports = function (app) {
    var sourceDir = '../source';

    app.get('/getting-started/index.html', function (req, res)   { res.redirect('/user/returning-user-login.html');});

    //Redirect to Jade pages
    app.get('/'                            ,function (req, res)  { res.redirect('/default.html'                                                     );});
    app.get('/deploy/html/:area/:page.html',function (req, res)  { res.redirect('/'                 + req.params.area +'/'+req.params.page + '.html');}); 
    
    //Render Jade pages
    app.get('/:page.html'                  ,function (req, res)  { res.render  (sourceDir + '/html/'+ req.params.page                      + '.jade');}); 
    app.get('/:area/:page.html'            ,function (req, res)  { res.render  (sourceDir + '/html/'+ req.params.area +'/'+req.params.page + '.jade');}); 

    app.get('/dirName', function(req,res) { res.send(__dirname); } );
    app.get('/test'   , function(req,res) { res.send('from routes.js..'); } );
    app.get('/ping'   , function(req,res) { res.send('pong..' ); } );    
};