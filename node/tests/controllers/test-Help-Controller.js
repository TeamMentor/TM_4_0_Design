/*jslint node: true , expr:true */
/*global describe, it ,before, after */
"use strict";

var supertest         = require('supertest')   ,    
    expect            = require('chai').expect ,        
    request           = require('request')     ,    
    app               = require('../../server'),    
    Help_Controller   = require('../../controllers/Help-Controller.js');

describe('controllers |', function ()
{
    describe('test-Help-Controller.js |', function() 
    {   
        this.timeout(3500)
        
        describe('content_cache', function() 
        {
            it('check ctor', function()
                {
                    var help_Controller = new Help_Controller();
                    expect(Help_Controller).to.be.an("Function");
                    expect(help_Controller).to.be.an("Object");            
                    expect(help_Controller.content_cache).to.be.an("Object");
                    expect(help_Controller.title        ).to.equal(null);
                    expect(help_Controller.content      ).to.equal(null);
                }); 
            
            it('request should add to cache', function(done)
                {
                    var page = 'index.html';
                    var req = { params : { page : page              }};
                    var res = { status : function() { return this;  }};
                    var help_Controller = new Help_Controller(req,res);

                    help_Controller.content_cache[page] = undefined;    

                    var checkRequestCache = function(html)
                        {
                            var cacheItem = help_Controller.content_cache[page];
                            expect(cacheItem).to.be.an('Object');
                            expect(cacheItem.title  ).to.equal(help_Controller.pageParams.title);
                            expect(cacheItem.content).to.equal(help_Controller.pageParams.content); 
                             
                            help_Controller.clearContentCache();
                            
                            expect(help_Controller.content_cache[page]).to.be.undefined; 
                            done();
                        };                

                    res.send =  checkRequestCache;

                    expect(help_Controller.content_cache).to.be.an('Object');
                    //expect(help_Controller.content_cache[page]).to.be.undefined;

                    help_Controller.renderPage();
                });
            
            /*it('cache should return value set in cache', function(done)
                {
                    var help_Controller = new Help_Controller();
                    expect(help_Controller.content_cache["index.html"]).to.be.undefined;
                    //addContent
                    done();
                });*/
        });
        
        
        it('handle broken images bug', function(done)
        {         
            var gitHub_Path = 'https://raw.githubusercontent.com/TMContent/Lib_Docs/master/_Images/';
            var local_Path  = '/Image/';
            var test_image  = 'signup1.jpg';
            
            var check_For_Redirect = function()
                {                    
                    supertest(app).get(local_Path + test_image)
                                  .expect(302)
                                  .end(function(error, response)
                                        {
                                            expect(response.headers         ).to.be.an('Object');
                                            expect(response.headers.location).to.be.an('String');
                                            expect(response.headers.location).to.equal(gitHub_Path + test_image);
                                            check_That_Image_Exists(response.headers.location);
                                        });
                };
            var check_That_Image_Exists = function(image_Path)
                {                    
                    request.get(image_Path, function(error, response)
                        {
                            expect(response.statusCode).to.equal(200);
                            done();                         
                        });                          
                };
            
            check_For_Redirect();                            
        });
    });
});