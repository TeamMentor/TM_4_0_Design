/*jslint node: true */
"use strict";

var preCompiler       = require(process.cwd() + '/node/services/jade-pre-compiler.js');

var libraries = { "docs"  : { name : 'docs',
                              id   : 'eb39d862-f752-4d1c-ab6e-14ed697397c0' , 
                              repo : 'https://github.com/TMContent/Lib_Docs', 
                              site : 'https://docs.teammentor.net/' , 
                              title: 'TM Documentation'},
                  "vulns" : { name : 'vulns',
                              id   : 'be5273b1-d682-4361-99d9-6204f2d47eb7' , 
                              repo : 'https://github.com/TMContent/Lib_Vulnerabilities', 
                              site : 'https://vulnerabilities.teammentor.net/' , 
                              title: 'Vulnerabilities'}};
            
var Library_Controller = function(req, res) 
    {
        this.req        = req;
        this.res        = res;
        this.libraries  = libraries;
        this.showLibraries = function() 
            {                
                var viewModel = {'libraries' : this.libraries};
                                
                this.res.send(preCompiler.renderJadeFile('/source/html/libraries/list.jade', viewModel));                
            };
        this.showLibrary = function()
            {
                var name = (req && req.params) ? req.params.name : "";                
                var library = this.libraries[name];
                if(library)
                {
                    var viewModel = {'libraries' : this.libraries , library : library};
                                
                    this.res.send(preCompiler.renderJadeFile('/source/html/libraries/library.jade', viewModel));                    
                }
                else
                {
                    this.res.redirect('/Libraries');
                }
            }
    };
    
    
Library_Controller.registerRoutes = function (app)
    {
        //console.log('registering routes for Library Controller');
        app.get('/libraries'     , function (req, res) { new Library_Controller(req, res).showLibraries  (); });
        app.get('/library/:name' , function (req, res) { new Library_Controller(req, res).showLibrary    (); });
    };
module.exports = Library_Controller;  