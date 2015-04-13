express                 = require 'express'
bodyParser              = require('body-parser')
Login_Controller        = require('../../src/controllers/Login-Controller')
User_Sign_Up_Controller = require('../../src/controllers/User-Sign-Up-Controller')


describe '| controllers | User-Sign-Up-Controller', ->

  signUp_fail             = "source/jade/guest/sign-up-Fail.jade"
  signUpPage_Unavailable  = 'source/jade/guest/sign-up-cant-connect.jade'
  signUp_Ok               = '/guest/sign-up-OK.html'
  mainPage_user           = '/user/main.html'
  text_Short_Pwd          = 'Password must be 8 to 256 character long'
  text_Bad_Pwd            = 'Password must contain a non-letter and a non-number character'
  text_An_Error           = 'An error occurred'

  server                   = null
  url_WebServices          = null
  on_CreateUser_Response   = null
  users                    = {}
  passwordStrengthRegularExpression =///(
        #(?=.*\d)            # at least 1 digit
        #(?=.*[A-Z])         # at least 1 upper case letter
        (?=.*[a-z])         # at least 1 lower case letter
        (?=.*\W)            # at least 1 special character
        .                   # match any with previous validations
        {8,256}             # 8 to 256 characters
       )///

  add_TM_WebServices_Routes = (app)=>
    app.post '/Aspx_Pages/TM_WebServices.asmx/Login_Response', (req,res)=>
      username = req.body.username
      password = req.body.password
      if users[username] is password and password
        res.send { d: { Login_Status: 0}  }

    app.post '/Aspx_Pages/TM_WebServices.asmx/CreateUser_Response', (req,res)=>
      if on_CreateUser_Response
        return on_CreateUser_Response(req,res)

      username = req.body.newUser.username
      password = req.body.newUser.password
      email    = req.body.newUser.email
      if username and password and email

        if not (password.size().in_Between(7, 257))
          res.send { d: { Signup_Status: 1 , Validation_Results: [], Simple_Error_Message: text_Short_Pwd } }
          return

        if password.match(passwordStrengthRegularExpression)
          users[username] = password
          res.send { d: { Signup_Status: 0 , Validation_Results: [], Simple_Error_Message: 'sign-up ok' } }
          return

        res.send { d: { Signup_Status: 1 , Validation_Results: [{Message: text_Bad_Pwd }], Simple_Error_Message: '' } }
      else
        res.send { d: { Signup_Status: 1, Validation_Results: [] } }

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

  invoke_UserSignUp = (username, password, email, expected_Target, expected_ErrorMessage, callback)->
    req =
      session: {}
      url    : '/passwordReset/temp/00000000-0000-0000-0000-000000000000'
      body   : { username: username , password: password,'confirm-password':password , email: email }

    res =
      redirect: (target)->
        target.assert_Is(expected_Target)
        callback()
      render : (jade_Page, params) ->
        params.viewModel.errorMessage.assert_Is expected_ErrorMessage
        jade_Page.assert_Is(expected_Target)
        callback()

    using new User_Sign_Up_Controller(req, res), ->
      @.webServices = url_WebServices
      @.userSignUp()


  invoke_LoginUser = (username, password, expected_Target, callback)->
    req =
      session: {}
      url    : '/passwordReset/temp/00000000-0000-0000-0000-000000000000'
      body   : { username : username , password : password }

    res =
      redirect: (target)->
        target.assert_Is(expected_Target)
        callback()

    using new Login_Controller(req, res), ->
      @.webServices = url_WebServices
      @.loginUser()


  it 'userSignUp (webServices - bad server)', (done)->
    req = body : {}
    res =
      render: (jade_Page, params)->
        jade_Page.assert_Is signUpPage_Unavailable
        params.assert_Is { viewModel:{ username: undefined,password: undefined,confirmpassword: undefined,email: undefined,errorMessage: 'TEAM Mentor is unavailable, please contact us at '} }
        done()
    using new User_Sign_Up_Controller(req,res),->
      @.webServices = "http://aaaaaaa.teammentor.net"
      @userSignUp()

  it 'userSignUp (webServices - non 200 response)', (done)->
    on_CreateUser_Response = (req,res)->
      res.status(201).send {}

    req = body : {}
    res =
      render: (jade_Page, params)->
        jade_Page.assert_Is signUpPage_Unavailable
        params.assert_Is { viewModel:{ username: undefined,password: undefined,confirmpassword: undefined,email: undefined,errorMessage: 'TEAM Mentor is unavailable, please contact us at '} }
        done()

    using new User_Sign_Up_Controller(req,res),->
      @.webServices = url_WebServices
      @userSignUp()

  it 'userSignUp (webServices - null response)', (done)->
    on_CreateUser_Response = (req,res)->
      res.send null

    req = body : {}
    res =
      render: (jade_Page, params)->
        jade_Page.assert_Is signUpPage_Unavailable
        params.assert_Is { viewModel: { errorMessage: 'An error occurred' } }
        done()

    using new User_Sign_Up_Controller(req,res),->
      @.webServices = url_WebServices
      @userSignUp()

  it 'userSignUp (webServices - non json response)', (done)->
    on_CreateUser_Response = (req,res)->
      res.send 'aaaaaa'

    req = body : {}
    res =
      render: (jade_Page, params)->
        jade_Page.assert_Is signUpPage_Unavailable
        params.assert_Is { viewModel: { errorMessage: 'An error occurred' } }
        done()

    using new User_Sign_Up_Controller(req,res),->
      @.webServices = url_WebServices
      @userSignUp()

  it 'userSignUp (bad values)', (done)->
    on_CreateUser_Response = null
    invoke_UserSignUp       ''    ,'aa'     ,'aa@teammentor.net', signUp_fail, text_An_Error , ->  #empty username
      invoke_UserSignUp     'aaa' ,''       ,'aa@teammentor.net', signUp_fail, text_An_Error , ->  #empty password
        invoke_UserSignUp   'aa'  ,'aa'     ,''                 , signUp_fail, text_An_Error , ->  #empty email
          invoke_UserSignUp 'user','weakpwd','aa@teammentor.net', signUp_fail, text_Short_Pwd, ->  #weak password
            done()

  it 'userSignUp (good values)', (done)->
    user = "tm_ut_".add_5_Random_Letters()
    pwd  = "**tm**pwd**"
    email = "#{user}@teammentor.net"

    invoke_UserSignUp user,pwd,email,signUp_Ok,'', ->
      invoke_LoginUser user,pwd,mainPage_user, ->
        done()

  it 'userSignUp (pwd dont match)', (done)->
    req =
      body   : { password:'aa' , 'password-confirm':'bb'}
    res =
      render : (target) ->
        target.assert_Contains(signUp_fail)
        done()

    using new User_Sign_Up_Controller(req,res),->
      @.webServices = url_WebServices
      @userSignUp()


  it 'userSignUp (error handling)', (done)->
    req =
      body   : { password:'aa' , 'confirm-password':'aa'}
    res =
      render: (jade_Page, params)->
        jade_Page.assert_Is signUpPage_Unavailable
        params.assert_Is { viewModel:{ username: undefined,password: 'aa',confirmpassword:'aa',email: undefined,errorMessage: 'TEAM Mentor is unavailable, please contact us at ' } }
        done()
    using new User_Sign_Up_Controller(req,res),->
      @.webServices = 'https://aaaaaaaa.teammentor.net/'
      @userSignUp()

  it 'Persist HTML form fields on error (Passwords do not match)',(done)->
    newUsername         ='xy'.add_5_Letters()
    newPassword         ='aa'.add_5_Letters()
    newConfirmPassword  ='bb'.add_5_Letters()
    newEmail            ='ab'.add_5_Letters()+'@mailinator.com'

    #render contains the file to render and the view model object
    render = (html,model)->
        model.viewModel.username.assert_Is(newUsername)
        model.viewModel.password.assert_Is(newPassword)
        model.viewModel.confirmpassword.assert_Is(newConfirmPassword)
        model.viewModel.email.assert_Is(newEmail)
        model.viewModel.errorMessage.assert_Is('Passwords don\'t match')
        done()
    req = body:{username:newUsername,password:newPassword,'confirm-password':newConfirmPassword, email:newEmail};
    res = {render: render}

    using new User_Sign_Up_Controller(req, res), ->
      @.userSignUp()

  it 'Persist HTML form fields on error (Password too short)',(done)->
    newUsername         ='xy'.add_5_Letters()
    newPassword         ='aa'.add_5_Letters()
    newEmail            ='ab'.add_5_Letters()+'@mailinator.com'

    #render contains the file to render and the view model object
    render = (html,model)->
      model.viewModel.username.assert_Is(newUsername)
      model.viewModel.password.assert_Is(newPassword)
      model.viewModel.confirmpassword.assert_Is(newPassword)
      model.viewModel.email.assert_Is(newEmail)
      model.viewModel.errorMessage.assert_Is('Password must be 8 to 256 character long')
      done()
    req = body:{username:newUsername,password:newPassword,'confirm-password':newPassword, email:newEmail};
    res = {render: render}

    using new User_Sign_Up_Controller(req, res), ->
      @.webServices = url_WebServices
      @.userSignUp()


  it 'Persist HTML form fields on error (Password is weak)',(done)->
    newUsername         ='xy'.add_5_Letters()
    newPassword         ='aaa'.add_5_Letters()
    newEmail            ='ab'.add_5_Letters()+'@mailinator.com'

    #render contains the file to render and the view model object
    render = (html,model)->
      model.viewModel.username.assert_Is(newUsername)
      model.viewModel.password.assert_Is(newPassword)
      model.viewModel.confirmpassword.assert_Is(newPassword)
      model.viewModel.email.assert_Is(newEmail)
      model.viewModel.errorMessage.assert_Is('Password must contain a non-letter and a non-number character')
      done()
    req = body:{username:newUsername,password:newPassword,'confirm-password':newPassword, email:newEmail};
    res = {render: render}

    using new User_Sign_Up_Controller(req, res), ->
      @.webServices = url_WebServices
      @.userSignUp()