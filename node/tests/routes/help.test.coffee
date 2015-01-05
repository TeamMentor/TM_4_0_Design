supertest          = require('supertest')
expect             = require('chai').expect
cheerio            = require('cheerio')
marked             = require('marked')
request            = require('request')
fs                 = require('fs')
app                = require('../../server')
Jade_Service       = require('../../services/Jade-Service')
Help_Controller    = require('../../controllers/Help-Controller')
    

describe 'routes | help.test', ()->

  app.config.enable_Jade_Cache = true;       # enable Jade compilation cache (which dramatically speeds up tests)
    
  before ->
    app.server = app.listen();
    #preCompiler.disableCache = false;


  after ()->
    app.server.close()
        

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
