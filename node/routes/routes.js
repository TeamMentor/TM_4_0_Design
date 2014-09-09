/*jslint node: true */
"use strict";

var checkAuth = require('./auth');

module.exports = function (app) {
    var sourceDir = '../source';

    app.get('/getting-started/index.html'  , function (req, res)  { res.redirect('/user/login/returning-user-login.html');});

    //Redirect to Jade pages
    app.get('/'                            , function (req, res)  { res.redirect('/default.html'                                                     );});
    app.get('/deploy/html/:area/:page.html', function (req, res)  { res.redirect('/'                 + req.params.area +'/'+req.params.page + '.html');}); 
    
    //Render Jade pages
    app.get('/:page.html'                  , function (req, res)  { res.render  (sourceDir + '/html/'+ req.params.page                      + '.jade');}); 
    
    app.get('/user/login/:page.html'       , function (req, res)  { res.render  (sourceDir + '/html/user/login/'+req.params.page + '.jade');}); 
    app.get('/landing-pages/:page.html'    , function (req, res)  { res.render  (sourceDir + '/html/landing-pages/'+req.params.page + '.jade');}); 
    
    app.get('/:area/:page.html'            , checkAuth , function (req, res)  { res.render  (sourceDir + '/html/'+ req.params.area +'/'+req.params.page + '.jade');}); 
};