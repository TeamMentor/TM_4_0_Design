/*jslint node: true */
/*global describe, it, before, beforeEach, after */

"use strict";

var //assert   = require('assert'),
    expect   = require('chai').expect,
    Browser  = new require('zombie'),    
    app      = require('../../server'),
    browser;


describe('User Login sequence', function () 
{
    before(function() { app.server = app.listen(app.port); Browser.localhost("aaaalocalhost", app.port);});
    after (function() { app.server.close();                                                             });
    
    beforeEach(function(done)
    {
        browser = new Browser();
        browser.visit('/user/returning-user-login.html', 
                      function () 
                      {
                        done();
                      });
    });        

    it('Check login page Form fields ', function () 
    {
  
        browser.assert.text   ('h3','Login');                               // html elements

        browser.assert.attribute('form','method','post'         );          // login form
        browser.assert.attribute('form','action','/action/login');          // login form

        browser.assert.element('#new-user-username');                       // fields
        browser.assert.element('#new-user-password');


        browser.assert.element('#btn-login'     );                          // buttons
        browser.assert.element('#btn-forgot-pwd');            
        browser.assert.text   ('#btn-login'     ,'Login'                );
        browser.assert.text   ('#btn-forgot-pwd','Forgot your password?');                        
    });

    it('Submit from with bad data', function (done) 
    {
        var username = 'tm';
        var password = 'tmAAAA';
        browser.fill            ('#new-user-username'         , username);
        browser.assert.attribute('#new-user-username', 'value', username);
        browser.fill            ('#new-user-password'         , password);
        browser.assert.attribute('#new-user-password', 'value', password);
        browser.click('#btn-login', function()
        {
            browser.assert.url('http://localhost/user/returning-user-validation.html');            
            done();
        });        
    });
    
        it('Submit from with valid account', function (done) 
    {
        var username = 'tm';
        var password = 'tm';
        browser.fill            ('#new-user-username'         , username);
        browser.assert.attribute('#new-user-username', 'value', username);
        browser.fill            ('#new-user-password'         , password);
        browser.assert.attribute('#new-user-password', 'value', password);
        browser.click('#btn-login', function()
        {
            browser.assert.url('http://localhost/home/main-app-view.html');
            //expect(browser.url).to.contain('/action/login');                        
            done();
        });        
    });
    
});