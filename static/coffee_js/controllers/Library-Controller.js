/*jslint node: true */
"use strict";

var fs            = require('fs'),
    path          = require('path'),
    request       = require('request'),
    Config        = require('../Config'),
    Jade_Service  = require('../services/Jade-Service');

var libraries = { 
                  "Uno"   : { name : 'Uno',
                              id   : 'be5273b1-d682-4361-99d9-6234f2d47eb7' , 
                              repo : 'https://github.com/TMContent/Lib_UNO', 
                              site : 'https://tmdev01-uno.teammentor.net/' ,
                              title: 'Index',
                              data : null} ,
                  /*"Java"  : { name : 'Java',
                              id   : 'c4b9cb6a-4561-4451-9b6c-4e59d73584f6' , 
                              repo : 'https://github.com/TMContent/Lib_Java', 
                              site : 'https://tmdev01-sme.teammentor.net/' , 
                              title: 'Java',
                              data : null} ,
                  "docs"  : { name : 'docs',
                              id   : 'eb39d862-f752-4d1c-ab6e-14ed697397c0' , 
                              repo : 'https://github.com/TMContent/Lib_Docs', 
                              site : 'https://docs.teammentor.net/' , 
                              title: 'TM Documentation',
                              data : null},
                  /*"vulns" : { name : 'vulns',
                              id   : 'be5273b1-d682-4361-99d9-6204f2d47eb7' , 
                              repo : 'https://github.com/TMContent/Lib_Vulnerabilities', 
                              site : 'https://tmdev01-sme.teammentor.net/' , 
                              title: 'Vulnerabilities',
                              data : null},*/
                  "html5" : { name : 'html5',
                              id   : '7d2d0571-e542-45cd-9335-d7a0556c2bea' , 
                              repo : 'https://github.com/TMContent/Lib_Html5', 
                              site : 'https://tmdev01-sme.teammentor.net/' , 
                              title: 'Html 5',
                              data : null}                
                              
                };
            
            
var Library_Controller = function(req, res, config) 
    {        
        this.req          = req;
        this.res          = res;
        this.libraries    = libraries;     
        this.config       = config || new Config();
        this.jade_Service = new Jade_Service(this.config);
        
        this.showLibraries = function() 
            {       
                var viewModel = {'libraries' : this.libraries};
                                
                this.res.send(this.jade_Service.renderJadeFile('/source/jade/user/list.jade', viewModel));
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
                            that.res.send(that.jade_Service.renderJadeFile('/source/jade/user/library.jade', viewModel));
                        });
                    
                }
                else
                {
                    this.res.redirect('/Libraries');
                }
            };
        this.showQueries = function()
        {
            var server = 'http://localhost:1332';
            var url    = '/data/tm-uno/queries';
            var that   = this;
            request(server + url, function(error, response,data)
                {
                    var graph = JSON.parse(data);
                    var nodes = graph.nodes;
                    var node_Labels = [];
                    nodes.forEach(function(node){node_Labels.push(node.label);});                    
                    var viewModel = {'queries' : node_Labels.sort()};
                    that.res.send(that.jade_Service.renderJadeFile('/source/jade/user/queries.jade', viewModel));
                    //that.res.send(nodes)
                });            
        };
        this.showFolder = function()
            {
                var library_name = (req && req.params) ? req.params.library : "";
                var folder_name = (req && req.params) ? req.params.folder : "";
                
                var library = this.libraries[library_name];                                
                
                if(library)    
                {
                    var that = this;
                    this.mapLibraryData(library, function()
                        {
                            //console.log('found library');
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
                                that.res.send(that.jade_Service.renderJadeFile('/source/jade/user/folder.jade', viewModel));
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
            var cachedLibrary = this.cachedLibraryData(library);            
            if (cachedLibrary)
            {
                library.data = cachedLibrary.data;
            }            
            if(library.data)
            {
                //console.log('library.data is already loaded, skiping load'); 
                next();
                return;
            }
            
            var url  = library.site + 'rest/library/' + library.id;    
            var that = this;
            request.get({url: url, json:true}, function(error, request, body)
                {
                    if(error) { throw error; }
                    library.data = body;                    
                    that.cacheLibraryData(library);
                    next();
                });

        };
        this.cachedLibraryData = function(library)
        {
            if(library && library.id)
            {
                var cacheFile =  this.cachedLibraryData_File(library); //path.join(this.config.library_Data, library.id + ".json");
                if (fs.existsSync(cacheFile))
                {
                    var fileContents = fs.readFileSync(cacheFile, 'utf8');                     
                    if (fileContents)
                    {                    
                        return JSON.parse(fileContents);                        
                    }
                }
            }
            return null;
        };
        this.cacheLibraryData = function(library)
        {
            if(library && library.id)
            {
                var cacheFile =  this.cachedLibraryData_File(library);
                fs.writeFileSync(cacheFile, JSON.stringify(library));
                return cacheFile;
            }
            return null;
        };
        this.cachedLibraryData_File = function(library)
        {
            if(library && library.id)
                return  path.join(this.config.library_Data, library.id + ".json");
            return null;
        };
    };

var auth                = require('../middleware/auth')

Library_Controller.registerRoutes = function (app)
    {
        //console.log('registering routes for Library Controller');
        app.get('/libraries'                       , function (req,res,next) { auth.checkAuth(req, res,next, app.config);}  , function (req, res) { new Library_Controller(req, res, app.config).showLibraries  (); });
        app.get('/library/queries'                 , function (req,res,next) { auth.checkAuth(req, res,next, app.config);}  , function (req, res) { new Library_Controller(req, res, app.config).showQueries    (); });
        app.get('/library/:name'                   , function (req,res,next) { auth.checkAuth(req, res,next, app.config);}  , function (req, res) { new Library_Controller(req, res, app.config).showLibrary    (); });
        app.get('/library/:library/folder/:folder' , function (req,res,next) { auth.checkAuth(req, res,next, app.config);}  , function (req, res) { new Library_Controller(req, res, app.config).showFolder     (); });
    };
module.exports = Library_Controller;


