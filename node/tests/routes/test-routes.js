/*jslint node: true */
/*global describe, it, before, after */
"use strict";

var assert   = require('chai').assert, 
    expect   = require('chai').expect, 
    Browser  = require('zombie'),    
    app      = require('../../server');    
    
describe('routes | test-routes.js |', function () 
{
    before(function() { app.server = app.listen(app.port); Browser.localhost("localhost", app.port);});
    after (function() { app.server.close();                                                             });
    
    describe('routes step up |', function() 
    {
        it('Check app variable/import', function ()
        {        
            expect(app        ).to.be.a('function');
            expect(app._router).to.be.a('function');
        });
        
        it('Check expected paths',function()
        { 
            var paths = [];
            var routes = app._router.stack;

            routes.forEach(function(item) 
            {
                if (item.route) { paths.push(item.route.path);}
            });
            console.log(paths)
            //console.log(paths);  
            var expectedPaths = [   '/:version/articles/:page',
                                    '/:version/error-pages/:page',
                                    '/:version/getting-started/:page',
                                    '/:version/help/:page',
                                    '/:version/home/:page',
                                    '/:version/landing-pages/:page',
                                    '/:version/learning-paths/:page',
                                    '/:version/new-user-onboard/:page',
                                    '/:version/style-guide/:page',
                                    '/:version/user/:page',
                                    '/:version/default',
                                    '/flare/all',
                                    '/flare',
                                    '/flare/main-app-view',
                                    '/user/login',
                                    '/user/login',
                                    '/user/logout',
                                    '/user/pwd_reset',
                                    '/user/sign-up',
                                    '/libraries',
                                    '/library/queries',
                                    '/library/:name',
                                    '/library/:library/folder/:folder',
                                    '/graph/:queryId',
                                    '/graph/:queryId/:filters',
                                    '/user/main.html',
                                    '/article/view/:guid/:title',
                                    '/help/:page*',
                                    '/Image/:name',
                                    '/',
                                    '/index.html',
                                    '/guest/:page.html',
                                    '/user/login/:page.html',
                                    '/',
                                    '/deploy/html/:area/:page.html',
                                    '/module',
                                    '/mainModule',
                                    '/session',
                                    '/dirName',
                                    '/pwd',
                                    '/test',
                                    '/ping',
                                    '/version',
                                    '/config' ];

            expect(paths.length).to.be.equal(expectedPaths.length);
            paths.forEach(function(path)
            {
                expect(expectedPaths).to.contain(path);
            });        
        });  
    });    
});