/*jslint node: true */
/*global describe, it, before, after */

"use strict";

var Browser  = require('zombie'),
    expect   = require('chai').expect,
    app      = require('../../server');
    


describe('Node Server Setup', function () {
    
    before(function() { app.server = app.listen(app.port); Browser.localhost("localhost", app.port);});
    after (function() { app.server.close();                                                             });

    
    it('Node WebServer is up', function (done) 
    {
        Browser.visit('/default.html', function (err, browser) {
            if (err) { throw err; }
            expect(browser.url).to.contain('/default.html');     
            done();  
        }); 
    });

    it('Call to / should redirect to default.html', function (done) 
    {
        Browser.visit('/', function (err, browser) {
            if (err) { throw err; }
            expect(browser.url).to.contain('/default.html');     
            done(); 
        });
    });
});