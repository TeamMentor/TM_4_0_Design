require 'fluentnode'

app             = null
express_Service = null
expect          = null

describe "| tm-server.test |", ->

  before ->
    express_Service  = require('../src/tm-server')
    app              = express_Service.app
    expect           = require('chai').expect

  it "Ctor values", ->
    expect(app              ).to.be.an('Function')
    expect(app.config       ).to.be.an('Object')
    expect(app._router.stack).to.be.an('Array')

  it 'start when not in mocha', (done)->
    # for this to work we need to reload app and manipulate: process.mainModule.filename and process.env.PORT
    originalName = process.mainModule.filename

    process.mainModule.filename.assert_Contains('node_modules/mocha/bin/_mocha')

    process.mainModule.filename = '...'
    process.env.PORT            = (10000).random().add 10000

    url = "http://localhost:#{process.env.PORT}"
    url.GET (html)->
        (done(); return;)  if (html) # log "Server already running

        assert_Is_Null(html)
        for file in require.cache.keys()
          if file.contains(['TM_4_0_Design','src','tm-server']) and file.not_Contains(['.test.'])
            pathToApp = file
            break

        pathToApp.assert_File_Exists()
        require.cache[pathToApp].assert_Is_Object()
        delete require.cache[pathToApp]

        express_Service.logging_Service.restore_Console()
        express_Service  = require('../src/tm-server')
        app              = express_Service.app

        global.info.assert_Is console.log

        url.http_GET_With_Timeout (html)->
            app.server.assert_Is_Object()
            app.server.close()
            url.GET (html)->
              assert_Is_Null(html)
              process.mainModule.filename = originalName              # restore the value
              process.mainModule.filename.assert_Contains('node_modules/mocha/bin/_mocha')
              delete process.env.PORT
              express_Service.logging_Service.restore_Console()
              done()

