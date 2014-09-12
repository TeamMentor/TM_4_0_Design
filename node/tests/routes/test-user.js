/*jslint node: true */
/*global describe, it, before, beforeEach, after */

"use strict";

var assert   = require('assert'),    
    Browser  = new require('zombie'),    
    app      = require('../../server'),
    browser;

describe('routes > test-user.js', function ()
{
    describe('User Login sequence', function () 
    {
        before(function() { app.server = app.listen(app.port); Browser.localhost("localhost", app.port);});
        after (function() { app.server.close();                                                             });

        beforeEach(function(done)
        {
            browser = new Browser();
            browser.visit('/user/login/returning-user-login.html')
                   .then(done)
                   .fail(function(error) { assert.fail('error');});                      
        });        

        it('Check login page Form fields ', function () 
        {

            browser.assert.text     ('h3','Login');                           // html elements

            browser.assert.attribute('form','method','post'         );        // login form
            browser.assert.attribute('form','action','/user/login');          // login form

            browser.assert.element  ('#new-user-username');                   // fields
            browser.assert.element  ('#new-user-password');


            browser.assert.element('#btn-login'     );                        // buttons
//            browser.assert.element('#btn-forgot-pwd');            
            browser.assert.text   ('#btn-login'     ,'Login'                );
//            browser.assert.text   ('#btn-forgot-pwd','Forgot your password?');                        
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
                browser.assert.url('http://localhost/user/login/returning-user-validation.html');            

                browser.visit('/session', function()
                {
                    var session = JSON.parse(browser.text('body'), true);                
                    assert.equal(session.username, undefined);  
                    done();
                });
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

                //check that session username is set
                browser.visit('/session', function()
                {
                    var session = JSON.parse(browser.text('body'), true);                
                    assert.equal(session.username, username);  
                    done();
                });            
            });        
        });    
    });
});