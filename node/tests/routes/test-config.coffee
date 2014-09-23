app       = require('../../server')
expect    = require('chai').expect
supertest = require('supertest')

describe "routes | test-config.coffee |", ->

    it "/version", (done) ->
        supertest(app).get('/version')
                          .expect(200, app.config.version, done)
    
    it "/config", (done) ->
        supertest(app).get('/config')
                          .expect(200, app.config        , done)
                          