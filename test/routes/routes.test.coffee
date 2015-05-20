supertest       = null
Express_Service = null
request         = null

describe '| routes | routes.test |', ()->

    @.timeout 7000
    express_Service = null
    app             = null

    expectedPaths = [ '/'
                      '/flare/_dev/:area/:page'
                      '/flare/_dev/all'
                      '/flare/_dev'
                      '/flare/:page'
                      '/flare'
                      '/Image/:name'
                      '/a/:ref'
                      '/article/:ref/:guid'
                      '/article/:ref/:title'
                      '/article/:ref'
                      '/teamMentor/open/:guid'
                      '/teamMentor'
                      '/articles'
                      '/search'
                      '/search/:text'
                      '/show'
                      '/show/:queryId'
                      '/show/:queryId/:filters'
                      '/render/mixin/:file/:mixin'   # GET
                      '/render/mixin/:file/:mixin'   # POST (test blind spot due to same name as GET)
                      '/render/file/:file'
                      '/guest/:page.html'
                      '/guest/:page'
                      '/passwordReset/:username/:token'
                      '/help/index.html'
                      '/help/:page*'
                      '/help/article/:page*'
                      '/misc/:page'
                      '/index.html'
                      '/user/login'
                      '/user/login'
                      '/user/logout'
                      '/_Customizations/SSO.aspx'
                      '/Aspx_Pages/SSO.aspx'
                      '/user/main.html'
                      '/user/pwd_reset'
                      '/user/sign-up'
                      '/passwordReset/:username/:token'
                      '/error'
                      '/poc*'
                      '/poc'
                      '/poc/filters:page'
                      '/poc/filters:page/:filters'
                      '/poc/:page'
                      '/*']

    dependencies = ->
      supertest       = require 'supertest'
      Express_Service = require '../../src/services/Express-Service'
      request         = require('superagent')

    before ()->
      dependencies()
      options =
        logging_Enabled : false
        port            : 1024 + (20000).random()

      express_Service  = new Express_Service(options).setup().start()

      app              = express_Service.app
      #app.server       = app.listen();

    after ()->
      app.server.close()
      #express_Service.logging_Service.restore_Console()


    it 'Check expected paths', ()->
        paths = []
        routes = app._router.stack;

        routes.forEach (item)->
            if (item.route)
              paths.push(item.route.path)

        #console.log("\nsorted paths: " + paths.sort())

        paths.length.assert_Is(expectedPaths.length)
        paths.forEach (path)->
            expectedPaths.assert_Contains(path,"Path not found: #{path}")

  #dynamically create the tests
    runTest = (originalPath) ->
      path = originalPath.replace(':version','flare')
                         .replace(':area/:page','help/index')
                         .replace(':file/:mixin', 'globals/tm-support-email')
                         #.replace(':area','help')
                         .replace(':page','default')
                         .replace(':queryId','AAAA')
                         .replace(':filters','BBBB')
                         .replace('*','aaaaa')


      expectedStatus = 200;
      expectedStatus = 302 if ['','image','deploy', 'poc'                         ].contains(path.split('/').second().lower())
      expectedStatus = 302 if ['/flare','/flare/_dev','/flare/main-app-view','/user/login',
                               '/user/logout','/pocaaaaa','/teamMentor'           ].contains(path)

      expectedStatus = 403 if ['a','article','articles','show'                    ].contains(path.split('/').second().lower())
      expectedStatus = 403 if ['/user/main.html', '/search', '/search/:text'      ].contains(path)
      expectedStatus = 403 if path is '/teamMentor/open/:guid'
      expectedStatus = 404 if ['/aaaaa'                                           ].contains(path)
      expectedStatus = 500 if ['/error'                                           ].contains(path)

      postRequest = ['/user/pwd_reset','/user/sign-up'                            ].contains(path)

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

    it 'Issue_679_Validate authentication status on error page', (done)->
      agent = request.agent()
      baseUrl = 'http://localhost:' + app.port

      loggedInText = ['<span title="Logout" class="icon-Logout">']
      loggedOutText = ['<li><a id="nav-login" href="/guest/login.html">Login</a></li>']

      postData = {username:'user', password:'a'}
      userLogin = (agent, postData, next)-> agent.post(baseUrl + '/user/login').send(postData).end (err,res)->
        assert_Is_Null(err)
        next()
      userLogout = (next)-> agent.get(baseUrl + '/user/logout').end (err,res)->
        res.status.assert_Is(200)
        next()

      get404 = (agent, text, next)-> agent.get(baseUrl + '/foo').end (err,res)->
        res.status.assert_Is(404)
        res.text.assert_Contains(text)
        next()
      get500 = (agent, text, next)-> agent.get(baseUrl + '/error?{#foo}').end (err,res)->
        res.status.assert_Is(500)
        res.text.assert_Contains(text)
        next()

      userLogin agent,postData, ->
        get404 agent,loggedInText, ->
          get500 agent,loggedInText, ->
            userLogout ->
              get404 agent, loggedOutText, ->
                get500 agent, loggedOutText, ->
                  done()