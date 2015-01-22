require 'fluentnode'

app = require('../server')

expect =  require('chai').expect

describe "test-server.js |", ->

  it "Ctor values", ->
    expect(app              ).to.be.an('Function')
    expect(app.config       ).to.be.an('Object')
    expect(app._router.stack).to.be.an('Array')

  it 'start when not in mocha', (done)->
    # for this to work we need to reload app and manipulate: process.mainModule.filename and process.env.PORT

    originalName = process.mainModule.filename

    process.mainModule.filename.assert_Contains('node_modules/mocha/bin/_mocha')

    process.mainModule.filename = '...'
    process.env.PORT            = 1337 + 10
    url = "http://localhost:#{process.env.PORT}"
    url.GET (html)->
        assert_Is_Null(html)
        for file in require.cache.keys()
          if file.contains(['node/server.coffee']) or  file.contains(['node-cov/server.js'])
            pathToApp = file
            break

        require.cache[pathToApp].assert_Is_Object()
        delete require.cache[pathToApp]

        app = require '../server'

        url.GET (html)->

            app.server.assert_Is_Object()
            app.server.close()
            url.GET (html)->
              assert_Is_Null(html)
              process.mainModule.filename = originalName              # restore the value
              process.mainModule.filename.assert_Contains('node_modules/mocha/bin/_mocha')
              delete process.env.PORT
              done()

