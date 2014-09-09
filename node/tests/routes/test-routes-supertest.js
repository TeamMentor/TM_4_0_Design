/*jslint node: true */
/*global describe, it, before, after */
"use strict";

var supertest = require('supertest')  ,  
    app       = require('../../server');    

describe('test-routes.js (using supertest)', function () 
{
    before(function() { app.server = app.listen(app.port);});
    after (function() { app.server.close();                                                             });
    
    describe('for tm', function() 
    {
        it('/ping', function(done)
        {
            supertest(app).get('/ping')
                          .expect(200, 'pong..',done);
        });
        it('/user/logout', function(done)
        {
            supertest(app).get('/user/logout')
                          .expect(302, 'Moved Temporarily. Redirecting to /landing-pages/index.html',done);
        });
    });
});
