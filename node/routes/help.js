/*jslint node: true */
"use strict";

var Help_Controller   = require('../controllers/Help_Controller');

module.exports = function(app)
                    {                        
                        app.get('/help/:page*' , function (req, res) { new Help_Controller(req, res).renderPage(); });
                        app.get('/Image/:name' , Help_Controller.redirectImagesToGitHub);    
                        //app.get('/Image/:name', function (req, res) { res.redirect(gitHubImagePath + req.params.name); } );
                    };

/*var help_Routes = 
    {
        registerRoutes : function(app)
                            {
                                app.get('/help/:page*' , function (req, res)  
                                {    
                                    new Help_Controller(req, res).renderPage();                                    
                                });
                            }
    };

module.exports = help_Routes.registerRoutes;*/