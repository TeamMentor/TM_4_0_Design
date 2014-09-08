/*jslint node: true */
/*global describe, it, before, after */
"use strict";

var assert   = require('chai').assert, 
    Browser  = require('zombie'),    
    app      = require('../../server');    
    
describe('Check routes', function () 
{
    before(function() { app.server = app.listen(app.port); Browser.localhost("aaaalocalhost", app.port);});
    after (function() { app.server.close();                                                             });
    
    it('ping', function (done) 
    {
        
        Browser.visit('ping', function (err, browser) {            
            assert.equal(browser.text("body" ),"pong....");
            done();
        });
    });
    it('Special Redirects', function(done) 
    {
        
        Browser.visit('getting-started/index.html', function(err, browser) 
        {
            assert.include(browser.url, '/user/returning-user-login.html');
            done();
        });        
    });
});