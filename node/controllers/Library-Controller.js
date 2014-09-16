/*jslint node: true */
"use strict";

var request           = require('request'),
    preCompiler       = require(process.cwd() + '/node/services/jade-pre-compiler.js');

var libraries = { 
                  "Uno"   : { name : 'Uno',
                              id   : 'ea854894-8e16-46c8-9c61-737ef46d7e82' , 
                              repo : 'https://github.com/TMContent/Lib_UNO', 
                              site : 'https://tmdev01-sme.teammentor.net/' , 
                              title: 'Principles and Standards',
                              data : null} ,  
                  "docs"  : { name : 'docs',
                              id   : 'eb39d862-f752-4d1c-ab6e-14ed697397c0' , 
                              repo : 'https://github.com/TMContent/Lib_Docs', 
                              site : 'https://docs.teammentor.net/' , 
                              title: 'TM Documentation',
                              data : null},
                  "vulns" : { name : 'vulns',
                              id   : 'be5273b1-d682-4361-99d9-6204f2d47eb7' , 
                              repo : 'https://github.com/TMContent/Lib_Vulnerabilities', 
                              site : 'https://tmdev01-sme.teammentor.net/' , 
                              title: 'Vulnerabilities',
                              data : null},
                  "html5" : { name : 'html5',
                              id   : '7d2d0571-e542-45cd-9335-d7a0556c2bea' , 
                              repo : 'https://github.com/TMContent/Lib_Html5', 
                              site : 'https://tmdev01-sme.teammentor.net/' , 
                              title: 'Html 5',
                              data : null}                  
                              
                };
            
            
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
                    var that  = this;
                    this.mapLibraryData(library, function()
                        {
                            //console.log(viewModel.library.data.subFolders);
                            //viewModel.library = JSON.stringify(viewModel.library.data.subfolders);
                            that.res.send(preCompiler.renderJadeFile('/source/html/libraries/library.jade', viewModel));                        
                        });
                    
                }
                else
                {
                    this.res.redirect('/Libraries');
                }
            };
        this.showFolder = function()
            {
                var library_name = (req && req.params) ? req.params.library : "";
                var folder_name = (req && req.params) ? req.params.folder : "";
                
                var library = this.libraries[library_name];
                
                console.log();
                
                if(library)    
                {
                    var that = this;
                    this.mapLibraryData(library, function()
                        {
                            console.log('found library');
                            var subFolders = library.data.subFolders;
                            var folder = null;
                            subFolders.forEach(function(subFolder)
                                {
                                    if (subFolder.name === folder_name )
                                    {
                                        folder = subFolder;
                                        return false; 
                                    }
                                });
                            if (folder)
                            {
                                var viewModel = { libraries : that.libraries , 
                                              library   : library,
                                              folder    : folder};
                                that.res.send(preCompiler.renderJadeFile('/source/html/libraries/folder.jade', viewModel));                        
                            }
                            else
                                that.res.send('Folder not found: ' + folder_name);          // vuln to XSS
                            
                        });
                    
                }
                else
                {
                    this.res.send('Library not found: ' + library_name);
                }
                
            };
        
        this.mapLibraryData = function(library, next)
        {
            if(library.data)
            {
                console.log('library.data is already loaded, skiping load');
                next();
                return;
            }
            var url = library.site + 'rest/library/' + library.id;            
            request.get({url: url, json:true}, function(error, request, body)
                {
                    if(error)
                        throw error;                    
                    library.data = body;                    
                    next();
                });

        };
    };
    
    
Library_Controller.registerRoutes = function (app)
    {
        //console.log('registering routes for Library Controller');
        app.get('/libraries'                      , function (req, res) { new Library_Controller(req, res).showLibraries  (); });
        app.get('/library/:name'                   , function (req, res) { new Library_Controller(req, res).showLibrary   (); });
        app.get('/library/:library/folder/:folder' , function (req, res) { new Library_Controller(req, res).showFolder    (); });
    };
module.exports = Library_Controller;  