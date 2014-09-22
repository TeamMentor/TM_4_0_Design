app       = require('../../server')
expect    = require('chai').expect
supertest = require('supertest')

describe "test-config.js |", ->

    it "Ctor values", (done) ->
        supertest(app).get('/version')
                          .expect(200, app.config.version, done)