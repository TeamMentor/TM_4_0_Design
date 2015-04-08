express                 = require 'express'
bodyParser              = require('body-parser')
Login_Controller        = require('../../src/controllers/Login-Controller')


describe '| controllers | Login-Controller.test |', ->

  #consts
  loginPage                 = 'source/jade/guest/login-Fail.jade'
  loginPage_Unavailable     = 'source/jade/guest/login-cant-connect.jade'
  mainPage_user             = '/user/main.html'
  mainPage_no_user          = '/guest/default.html'
  password_sent             = '/guest/pwd-sent.html'
  password_reset_fail       = 'source/jade/guest/pwd-reset-fail.jade'
  password_reset_ok         = 'source/jade/guest/login-pwd-reset.html'
  blank_credentials_message = 'Invalid Username or Password'

  #mocked server
  server                   = null
  url_WebServices          = null
  users                    =  { tm: 'tm' , user: 'a'  }
  on_Login_Response        = null

  add_TM_WebServices_Routes = (app)=>
    app.post '/Aspx_Pages/TM_WebServices.asmx/Login_Response', (req,res)=>
      if on_Login_Response
        return on_Login_Response(req, res)
      username = req.body.username
      password = req.body.password
      if users[username]
        if users[username] is password
          res.send { d: { Login_Status: 0}  }
        else
          res.send { d: { Login_Status: 1, Simple_Error_Message: 'Wrong Password'  } }
      else
        res.send { d: { Login_Status: 1, Validation_Results: [{Message: 'Bad user and pwd'} ] } }

  before (done)->
    random_Port     = 10000.random().add(10000)
    url_WebServices = "http://localhost:#{random_Port}/Aspx_Pages/TM_WebServices.asmx"
    app             = new express().use(bodyParser.json())
    add_TM_WebServices_Routes(app)
    server          = app.listen(random_Port)

    url_WebServices.GET (html)->
      html.assert_Is 'Cannot GET /Aspx_Pages/TM_WebServices.asmx\n'
      done()

  after ->
    server.close()

  invoke_Method = (method, body, expected_Target, callback)->
    req =
      session: {}
      url    : '/passwordReset/temp/00000000-0000-0000-0000-000000000000'
      body   : body

    res =
      redirect: (target)->
        target.assert_Is(expected_Target)
        callback()
      render : (target) ->
        target.assert_Is(expected_Target)
        callback()

    using new Login_Controller(req, res), ->
      @.webServices = url_WebServices
      @[method]()

  invoke_LoginUser = (username, password, expected_Target, callback)->
    invoke_Method "loginUser",
                  { username : username , password : password } ,
                  expected_Target,
                  callback

  it 'constructor', ->
    using new Login_Controller,->
      #@.users           .assert_Is_Array().second().username.assert_Is 'user'
      @.req             .assert_Is {}
      @.res             .assert_Is {}

    using new Login_Controller('req', 'res'),->
      @.req             .assert_Is 'req'
      @.res             .assert_Is 'res'

  it "loginUser (server not ok)", (done)->
    req = body: {username:'aaaa', password:'bbb'}
    res =
      render: (jade_Page, params)->
        jade_Page.assert_Is loginPage_Unavailable
        params.assert_Is { viewModel: {"username":"","password":"", errorMessage: "TEAM Mentor is unavailable, please contact us at " } }
        done()

    using new Login_Controller(req, res), ->
      @.webServices = 'http://aaaaaabbb.teammentor.net'
      @.loginUser()

  it "loginUser (server ok - null response)", (done)->
    on_Login_Response = (req,res)->
      res.send null

    invoke_LoginUser 'aaa','bbb', loginPage_Unavailable, ->
      on_Login_Response = null
      done()

  it "loginUser (bad username, password)", (done)->
    invoke_LoginUser '','', loginPage, ->                # empty username and pwd
      invoke_LoginUser 'aaa','', loginPage, ->           # empty pwd
        invoke_LoginUser '','bbb', loginPage, ->         # empty username
          invoke_LoginUser 'aaa','bbb', loginPage, ->    # bad username and pwd
            invoke_LoginUser '','bb', loginPage, ->      # blank username
              invoke_LoginUser 'aa','', loginPage, ->    # blank password
                invoke_LoginUser '','', loginPage,done   # blank credentials

  it "loginUser (local-good username, password)", (done)->
    invoke_LoginUser 'tm','tm', mainPage_user, ->
      invoke_LoginUser 'user','a', mainPage_user, done

  it "loginUser (undefined Login_Status using existential operator)", (done)->
    invoke_LoginUser undefined ,undefined , loginPage, done

  it 'logoutUser', (done)->
    invoke_Method "logoutUser", {} ,mainPage_no_user,done

  it 'redirectToLoginPage', (done)->
    invoke_Method "redirectToLoginPage", { } ,loginPage,done

  it 'invalid Username or Password (missing username)',(done)->
    newUsername  =''
    newPassword  = 'aaa'.add_5_Letters()

    #render contains the file to render and the view model object
    render = (jadePage,model)->
      #Verifying the message from the backend.
      model.viewModel.errorMessage.assert_Is(blank_credentials_message)
      jadePage.assert_Is('source/jade/guest/login-Fail.jade')
      done()
    req = body:{username:newUsername,password:newPassword},session:'';
    res = {render: render}

    using new Login_Controller(req, res) ,->
      @.loginUser()


  it 'invalid Username or Password (missing password)',(done)->
    newUsername         = 'aaa'.add_5_Letters()
    newPassword         =''

    #render contains the file to render and the view model object
    render = (jadePage,model)->
      model.viewModel.errorMessage.assert_Is(blank_credentials_message)
      #Verifying the message from the backend.
      jadePage.assert_Is('source/jade/guest/login-Fail.jade')
      done()
    req = body:{username:newUsername,password:newPassword},session:'';
    res = {render: render}

    using new Login_Controller(req, res) ,->
      @.loginUser()

  it 'invalid Username or Password (missing both username and password)',(done)->
    newUsername         =''
    newPassword         =''

    #render contains the file to render and the view model object
    render = (jadePage,model)->
      #Verifying the message from the backend.
      model.viewModel.errorMessage.assert_Is(blank_credentials_message)
      jadePage.assert_Is('source/jade/guest/login-Fail.jade')
      done()
    req = body:{username:newUsername,password:newPassword},session:'';
    res = {render: render}

    using new Login_Controller(req, res) ,->
      @.loginUser()

  it 'login form persist HTML form fields on error (Wrong Password)',(done)->
    newUsername         ='tm'
    newPassword         ='aaa'.add_5_Letters()

    #render contains the file to render and the view model object
    render = (html,model)->
      model.viewModel.username.assert_Is(newUsername)
      model.viewModel.password.assert_Is('')
      model.viewModel.errorMessage.assert_Is('Wrong Password')
      done()
    req = body:{username:newUsername,password:newPassword}, session:''
    res = render: render

    using new Login_Controller(req, res), ->
      @.webServices = url_WebServices
      @.loginUser()

  it 'login form persist HTML form fields on error (Wrong username)',(done)->
    newUsername         = 'aaa'.add_5_Letters()
    newPassword         = 'bbb'.add_5_Letters()

    render = (jade_Page,params)->
      jade_Page.assert_Is loginPage
      params.viewModel.errorMessage.assert_Is 'Bad user and pwd'
      done()

    req = body: {username:newUsername, password:newPassword}, session:''
    res = render: render

    using new Login_Controller(req, res), ->
      @.webServices = url_WebServices
      @.loginUser()


