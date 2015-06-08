supertest       = null
Express_Service = null
assert          = null

describe.only 'Content Security Policy headers tests', ()->
  express_Service = null
  app             = null

  dependencies = ->
    supertest       = require 'supertest'
    Express_Service = require '../../src/services/Express-Service'
    assert          = require 'assert'

  before ()->
    dependencies()
    options =
      logging_Enabled : false
      port            : 1024 + (20000).random()

    express_Service  = new Express_Service(options).setup().start()
    app              = express_Service.app

    after ()->
      app.server.close()

  it '| Verify security headers in response', (done)->
    supertest(app).get('/')
    .expect('Content-Security-Policy', "default-src 'self';script-src 'none';object-src 'self';img-src 'self';media-src 'none';frame-src 'self';style-src 'self';report-uri /csp")
    .end (err)->
      throw err if(err)
      done()