supertest = require('supertest')
app      = require('../../server')
    
describe 'routes | routes.test |', ()->
    expectedPaths = [ '/',
                      '/flare/:area/:page',
                      '/flare/default',
                      '/Image/:name',
                      '/article/:id'
                      '/article/viewed.json',
                      '/search',
                      '/flare',
                      '/flare/all',
                      '/flare/main-app-view',
                      '/-',
                      '/-/:queryId',
                      '/-/:queryId/:filters',
                      '/render/mixin/:file/:mixin',   # GET
                      '/render/mixin/:file/:mixin',   # POST (test blind spot due to same name as GET)
                      '/render/file/:file',
                      '/guest/:page.html',
                      '/passwordReset/:username/:token',
                      '/help/:page*',
                      '/index.html',
                      '/libraries',
                      '/library/:name',
                      '/user/login',
                      '/user/login',
                      '/user/logout',
                      '/user/main.html',
                      '/user/pwd_reset',
                      '/user/sign-up',
                      '/passwordReset/:username/:token'
                       '/-poc-'
                       '/*']

    before ()->
      app.server = app.listen();

    after ()->
      app.server.close()


    it 'Check expected paths', ()->
        paths = []
        routes = app._router.stack;

        routes.forEach (item)->
            if (item.route)
              paths.push(item.route.path)

        #console.log(paths.sort())

        paths.length.assert_Is(expectedPaths.length)
        paths.forEach (path)->
            expectedPaths.assert_Contains(path,"Path not found: #{path}")

  #dynamically create the tests
    runTest = (originalPath) ->
      path = originalPath.replace(':version','flare')
                         .replace(':area/:page','help/index')
                         .replace(':file/:mixin', 'globals/navigate-icon')
                         #.replace(':area','help')
                         .replace(':page','default')
                         .replace(':queryId','AAAA')
                         .replace(':filters','BBBB')
                         .replace('.*','aaaaa')

      expectedStatus = 200;
      expectedStatus = 302 if ['','image','deploy'                           ].contains(path.split('/').second().lower())
      expectedStatus = 302 if ['/flare','/flare/main-app-view','/user/login',
                               '/user/logout'                                ].contains(path)
      expectedStatus = 403 if ['article', '-','library','libraries'          ].contains(path.split('/').second().lower())
      expectedStatus = 403 if ['/user/main.html', '/search', '/search/:text' ].contains(path)
      expectedStatus = 403 if ['/-poc-/search-two-column','/-poc-','/-poc-/md-render'].contains(path)

      expectedStatus = 200 if ['/article/viewed.json'                        ].contains(path)

      expectedStatus = 404 if ['/aaaaa'                                      ].contains(path)

      postRequest = ['/user/pwd_reset','/user/sign-up'                       ].contains(path)

      testName = "[#{expectedStatus}] #{originalPath}" + (if(path != originalPath) then "  (#{path})" else  "")

      it testName, (done) ->

        checkResponse = (error,response) ->
          assert_Is_Null(error)
          response.text.assert_Is_String()
          done()
        if (postRequest)
          postData = {}
          postData ={username:"test",password:"somevalues",email:"someemail"} if path == '/user/sign-up'
          supertest(app).post(path).send(postData)
                        .expect(expectedStatus,checkResponse)
        else
          supertest(app).get(path)
                        .expect(expectedStatus,checkResponse)

    for route in expectedPaths
      runTest(route)