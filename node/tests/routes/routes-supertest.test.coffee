cheerio   = require('cheerio')
expect    = require('chai').expect
marked    = require('marked')
supertest = require('supertest')
app       = require('../../server')

describe 'routes | routes-supertest.test |',  ()->

  app.config.enable_Jade_Cache = true;

  it 'verify security headers in response', (done)->
    assert = require('assert')
    supertest(app).get('/')
                  .expect('Content-Security-Policy', "default-src 'self';script-src 'none';object-src 'self';img-src 'self';media-src 'none';frame-src 'self';style-src 'self';report-uri /csp")
                  .end (err)->
                    throw err if(err)
                    done()

  it 'should open page ok', (done)->
    supertest(app).get('/help/index.html')
                  .expect(200,done)

  it 'open /default.html', (done)->
    supertest(app).get('/guest/default.html')
                  .expect(200)
                  .end (err, res)->
                    throw err if(err)
                    $ = cheerio.load(res.text)
                    expect($('a').length).to.be.above(6);
                    expect($("a[href='/help/aaaaa.html'] ").length).to.be.empty;
                    expect($("a[href='/help/index.html']" ).length).to.be.not.empty;
                    done()