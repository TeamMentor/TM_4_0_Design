/*jslint node: true */
"use strict";

var auth                = require('../middleware/auth'),    
    Jade_Service        = require('../services/Jade-Service'),
    //preCompiler         = require(process.cwd() + '/node/services/jade-pre-compiler.js'),
    Help_Controller     = require('../controllers/Help-Controller'),
    Login_Controller    = require('../controllers/Login-Controller'),
    Library_Controller  = require('../controllers/Library-Controller'),
    Search_Controller   = require('../controllers/Search-Controller');
//console.log(jade);


module.exports = function (app) 
{
    
    //preCompiler.cleanCacheFolder();
    
    ///hard-coded-redirect
    //app.get('/getting-started/index.html'  , function (req, res)  { res.redirect('/user/login/returning-user-login.html');});


    //login routes (and temporarily also user-sign-up)
    
    app.get ('/user/login'     , function (req, res) { new Login_Controller(req, res).redirectToLoginPage(); });
    app.post('/user/login'     , function (req, res) { new Login_Controller(req, res).loginUser          (); });
    app.get ('/user/logout'    , function (req, res) { new Login_Controller(req, res).logoutUser         (); });
    app.post('/user/pwd_reset' , function (req, res) { new Login_Controller(req, res).passwordReset      (); });
    app.post('/user/sign-up'   , function (req, res) { new Login_Controller(req, res).userSignUp         (); });
    
    //library routes
    Library_Controller.registerRoutes(app);
    
    //search routes
    Search_Controller.registerRoutes(app);
    
    //help routes
    
    app.get('/help/:page*' , function (req, res) { new Help_Controller(req, res).renderPage            (); });
    app.get('/Image/:name' , function (req, res) { new Help_Controller(req, res).redirectImagesToGitHub(); });

    // jade (pre-compiled) pages (these have to be the last set of routes)

    app.get('/'                                             , function (req, res)  { res.send(new Jade_Service(app.config).renderJadeFile('/source/jade/guest/default.jade'                                                   ));});
    app.get('/:page.html'                                   , function (req, res)  { res.send(new Jade_Service(app.config).renderJadeFile('/source/jade/guest/'           + req.params.page + '.jade'                       ));});
    app.get('/user/login/:page.html'                        , function (req, res)  { res.send(new Jade_Service(app.config).renderJadeFile('/source/html/user/login/'              + req.params.page + '.jade'                       ));}); 
    //app.get('/bugs/:page.html'                              , function (req, res)  { res.send(new Jade_Service().renderJadeFile('/source/html/bugs/'              + req.params.page + '.jade'                       ));}); 
    app.get('/:area/:page.html'    , function (req,res,next) { auth.checkAuth(req, res,next, app.config);} 
                                                            , function (req, res)  { res.send(new Jade_Service(app.config).renderJadeFile('/source/html/' + req.params.area + '/' + req.params.page + '.jade'                       ));});     
    
    //Redirect to Jade pages
    app.get('/'                                             , function (req, res)  { res.redirect('/default.html'                                                     );});
    app.get('/deploy/html/:area/:page.html'                 , function (req, res)  { res.redirect('/'                 + req.params.area +'/'+req.params.page + '.html');});     
    
};