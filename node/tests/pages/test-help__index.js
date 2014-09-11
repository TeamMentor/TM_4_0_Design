/*jslint node: true */
/*global describe, it, before, after */
"use strict";

var supertest = require('supertest')  ,  
    app       = require('../../server'),
    Zombie    = require('zombie');

describe('pages', function () 
{
    before(function() { app.server = app.listen(app.port);   });
    after (function() { app.server.close();                                                           });
        
    describe('test-help__index.js', function() 
    {   
        it('should open page ok', function(done)
        {
            supertest(app).get('/help/index.html')
                          .expect(200,done); 
        });
        it('open /default.html', function(done)
        {
            Zombie.localhost("localhost", app.port);                         
            Zombie.visit('/default.html', function(err, browser) 
            {                 
                done();                
            });            
        });
        
        it('open help from /default.html', function(done)
        {
            Zombie.localhost("localhost", app.port);             
            
            Zombie.visit('/default.html', function(err, browser) 
            {                             
                browser.assert.url('http://localhost/default.html');
                browser.click(".nav-icons ul li a[href='/help/index.html' ]",function(err)
                {                    
                    browser.assert.url('http://localhost/help/index.html');
                    done();
                });
            });
        });
        
    });
});