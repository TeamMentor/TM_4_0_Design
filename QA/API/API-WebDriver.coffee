require 'fluentnode'
wd = require('wd')
chai = require("chai");

class API_WebDriver
  constructor:->
    @browser = null

  getBrowser: (callback)=>
    chaiAsPromised = require("chai-as-promised")
    chai.use(chaiAsPromised)
    chai.should()
    chaiAsPromised.transferPromiseness = wd.transferPromiseness;
    driver = wd.promiseChainRemote()
    driver.sessions (err, sessions)->
      sessionId = sessions.first().id
      browser = driver.attach sessionId
      callback(browser)

  dom: (callback)=>
    @browser.eval('document.body.innerHTML', (err,data)-> console.log(data))
            .then (html)->
                $ = cheerio.load(html)
                callback($)

module.exports = API_WebDriver