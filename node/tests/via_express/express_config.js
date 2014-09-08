/*jslint node: true */
/*global describe, it, after, before */
"use strict";

var expect  = require('chai').expect, 
    app     = require('../../server');


describe('Direct access to Express Objects', function ()
{
    before(function() { app.server = app.listen(app.port);});
    after (function() { app.server.close();               });
    
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
        
        var expectedPaths = [ '/',                                              
                              '/deploy/html/:area/:page.html',                  // jade page rendering
                              '/:page.html'                  ,
                              '/:area/:page.html'            ,
                             
                              '/getting-started/index.html'  ,                  // static redirects
                             
                              '/action/login'                ,                  // Authentication
                             
                              '/dirName'                     ,                  // test ones 
                              '/test',
                              '/ping' ];
        
        expect(paths.length).to.be.equal(expectedPaths.length);
        paths.forEach(function(path)
        {
            expect(expectedPaths).to.contain(path);
        });
        //expect(paths).to.be.deep.equal(expectedPaths);
//        console.log(paths);  
        
    }); 
});