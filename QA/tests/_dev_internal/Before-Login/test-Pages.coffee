return

API_WebDriver = require '../../API/API-WebDriver'
cheerio       = require 'cheerio'

describe 'test-Pages', ->
  browser = null
  api_WebDriver = new API_WebDriver()
  server = 'http://127.0.0.1:1337'


  before (done)->
    api_WebDriver.getBrowser (_browser)->
      browser = _browser
      done()

  it.only 'HomePage', (done)->
    browser.get(server + '/landing-pages/index.html')
           .then(done)

  it 'About', (done)->
    browser.get(server + '/landing-pages/about.html')
           .then(done)

  it 'Features', (done)->
    browser.get(server + '/landing-pages/features.html')
            .then(done)

  it 'Help', (done)->
    browser.get(server + '/help/index.html')
           .then(done)

  it 'Signup', (done)->
    browser.get(server + '/landing-pages/user-sign-up.html')
           .title().should.become('TEAM Mentor 4.0 (Html version)')
           .eval('document.body.innerHTML').then (html)->
                $ = cheerio.load(html)
                return $
           .then ($)->
              $('h3').html().assert_Is('Sign Up')
            .nodeify(done)


  it 'Login', (done)->
    browser.get(server + '/user/login/returning-user-login.html')
    .then(done)





