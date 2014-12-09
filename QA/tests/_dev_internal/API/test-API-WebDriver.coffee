return

API_WebDriver = require '../../API/API-WebDriver'

describe 'test-API-WebDriver', ->

  it 'getBrowser', (done)->
    API_WebDriver.assert_Is_Function()
    api_WebDriver = new API_WebDriver().assert_Is_Object()
    api_WebDriver.getBrowser (browser)->
      browser.assert_Is_Object().str()
      browser.title()
             .then (title)->
                title.assert_Is_String()
             .nodeify(done)

                #api_WebDriver.dom ($)->
                #  $.assert_Is_Object()


