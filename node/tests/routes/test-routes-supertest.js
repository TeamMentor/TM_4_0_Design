/*jslint node: true */
/*global describe, it */
"use strict";

var supertest = require('supertest')   ,  
    //expect    = require('chai').expect ,
    app       = require('../../server');

describe('routes | test-routes-supertest.js |',  function () 
{
    app.config.enable_Jade_Cache = true;
    
    describe('for tm', function() 
    {   
        it('/', function(done)
        {                
            supertest(app).get('/')
                          .expect(302, 'Moved Temporarily. Redirecting to /default.html',done);            


        });
        it('/default.html', function(done)
        {            
            supertest(app).get('/default.html')
                          .expect(200,done);
                          //.expect('Content-Length', '7144', done);
        });

        it('/user/logout', function(done)
        {
            supertest(app).get('/user/logout')
                          .expect(302, 'Moved Temporarily. Redirecting to /landing-pages/index.html',done);
        });
        it('/user/login', function(done)
        {
            supertest(app).get('/user/login')
                          .expect(302,'Moved Temporarily. Redirecting to /user/login/returning-user-validation.html',done);
        });

        //special redirect        
        it('/getting-started/index.html', function(done)
        {
            supertest(app).get('/getting-started/index.html')
                          .expect(302, 'Moved Temporarily. Redirecting to /user/login/returning-user-login.html',done);            
        });
    }); 

    describe('debug methods', function() 
    {
        it('/ping', function(done)
        {
            supertest(app).get('/ping')
                          .expect(200, 'pong..',done);
        });
        it('/session', function(done)
        {  
          var expectedSessionValue = '{"cookie":{"originalMaxAge":null,"expires":null,"httpOnly":true,"path":"/"}}';
      
            supertest(app).get('/session')
                          .expect(200, expectedSessionValue,done); 
            });
    });

    describe('authentication', function()  
    {
        it('for users not logged in (pages ok)', function(done)
        {
            var pages = ['/landing-pages/index.html','/landing-pages/about.html',
                         '/landing-pages/features.html'];
            var agent = supertest(app);
            var nextPage = function()
            {
                var page  = pages.pop();                
                //console.log('testing page: ' + page);
                agent.get(page).expect(200, function(error,response)
                {         
                    //console.log(" page error: " + error + " page html size: " + response.text.length);
                    if (error) { throw error; }
                    if (pages.length > 0) { nextPage(); }
                    else                  { done()    ; }
                });
            };

            nextPage();

        });

        it('for users not logged in (redirects ok)', function(done)
        {
            var pages = ['/home/main-app-view.html','/home/navigate.html', 
                         '/users/user.html'];
            var agent = supertest(app);
            var nextPage = function() 
            {
                var page  = pages.pop();                
                agent.get(page).expect(403, function(error)
                {                
                    if (error) { throw error; }
                    if (pages.length > 0) { nextPage(); }
                    else                  { done()    ; }
                });
            };
            nextPage();

        });        
    });       
});
