/*jslint node: true */
/*global describe, it */
"use strict";

var supertest = require('supertest')   ,  
    //expect    = require('chai').expect ,
    app       = require('../../server');

describe('routes | test-routes-supertest.js |',  function () 
{
    app.config.enable_Jade_Cache = true;

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
});
