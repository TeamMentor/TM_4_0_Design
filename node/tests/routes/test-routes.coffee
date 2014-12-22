assert   = require('chai').assert
expect   = require('chai').expect
supertest = require('supertest')
#Browser  = require('zombie')
app      = require('../../server')
    
describe.only 'routes | test-routes.js |', ()->
    expectedPaths = [ '/',
                      '/flare/:area/:page',
                      '/flare/default',
                      '/Image/:name',
                      '/article/view/:guid/:title',
                      '/config',
                      '/deploy/html/:area/:page.html',
                      '/dirName',
                      '/flare',
                      '/flare/all',
                      '/flare/main-app-view',
                      '/graph/:queryId',
                      '/graph/:queryId/:filters',
                      '/guest/:page.html',
                      '/help/:page*',
                      '/index.html',
                      '/libraries',
                      '/library/:library/folder/:folder',
                      '/library/:name',
                      '/library/queries',
                      '/mainModule',
                      '/module',
                      '/ping',
                      '/pwd',
                      '/session',
                      '/test',
                      '/user/login',
                      '/user/login',
                      '/user/logout',
                      '/user/main.html',
                      '/user/pwd_reset',
                      '/user/sign-up',
                      '/version' ]

    before ()->
      app.server = app.listen();

      #Browser.localhost("localhost", app.port)

    after ()->
      app.server.close()


    it 'Check expected paths', ()->
        paths = []
        routes = app._router.stack;

        routes.forEach (item)->
            if (item.route)
              paths.push(item.route.path)

        #console.log(paths.sort())

        expect(paths.length).to.be.equal(expectedPaths.length);
        paths.forEach (path)->
            expect(expectedPaths).to.contain(path);

  #dynamically create the tests
    runTest = (originalPath) ->
      path = originalPath.replace(':version','flare')
                         .replace(':area/:page','help/index')
                         #.replace(':area','help')
                         .replace(':page','default')
                         .replace(':queryId','AAAA')
                         .replace(':filters','BBBB')
      expectedStatus = 200;
      expectedStatus = 302 if ['image','deploy'                              ].contains(path.split('/').second().lower())
      expectedStatus = 302 if ['/flare','/flare/main-app-view','/user/login',
                               '/user/logout','/user/sign-up'                ].contains(path)
      expectedStatus = 403 if ['article', 'graph','library','libraries'      ].contains(path.split('/').second().lower())
      expectedStatus = 403 if ['/user/main.html'].contains(path)
      postRequest = ['/user/pwd_reset','/user/sign-up'].contains(path)

      testName = "[#{expectedStatus}] #{originalPath}" + (if(path != originalPath) then "  (#{path})" else  "")

      it testName, (done) ->

        checkResponse = (error,response) ->
          expect(error).to.equal(null)
          expect(response.text).to.not.equal('')
          done()
        if (postRequest)
          supertest(app).post(path).send({})
                        .expect(expectedStatus,checkResponse)
        else
          supertest(app).get(path)
                        .expect(expectedStatus,checkResponse)

    for route in expectedPaths
      runTest(route)