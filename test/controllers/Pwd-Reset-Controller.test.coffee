Pwd_Reset_Controller = require('../../src/controllers/Pwd-Reset-Controller')
express    = require 'express'
supertest  = require 'supertest'
bodyParser = require('body-parser')

describe "| controllers | Pwd-Reset-Controller.test |", ->

  url_password_sent          = '/guest/pwd-sent.html'
  #blank_credentials_message = 'Invalid Username or Password'
  app                     = null
  server                  = null
  url                     = null
  config                  = null
  pwd_Reset_Controller    = null
  on_SendPasswordReminder = ->
  on_PasswordReset        = ->

  before (done)->
    random_Port       = 10000.random().add(10000)
    url_Mocked_Server = "http://localhost:#{random_Port}/"
    app               = new express().use(bodyParser.json())
    app.post          '/tmWebServices/SendPasswordReminder', (req,res)-> on_SendPasswordReminder(req,res)
    app.post          '/tmWebServices/PasswordReset'       , (req,res)-> on_PasswordReset(req,res)
    server            = app.listen(random_Port)

    config            =
      tm_35_Server : url_Mocked_Server
      tmWebServices: 'tmWebServices'

    pwd_Reset_Controller = new Pwd_Reset_Controller({}, {}, { config: config })

    url_Mocked_Server.GET (html)->
      html.assert_Is 'Cannot GET /\n'
      done()

  after ->
    server.close()

  it 'passwordReset (no email , 201 ws response)', (done)->
    ws_Called = false
    using pwd_Reset_Controller,->
      @.req = {}
      @.res =
        redirect: (target)->
          target.assert_Is '/error'
          ws_Called.assert_True()
          done()
        render : (target,model)->
          model.assert_Is_Not_Undefined
          model.errorMessage?.assert_Is('TEAM Mentor is unavailable, please contact us at ')
          target.assert_Is('source/jade/guest/login-cant-connect.jade')
          done()

      on_SendPasswordReminder = (ws_req, ws_res)->
        ws_req.body.assert_Is {}
        ws_Called = true
        ws_res.status(201).send()

      @.password_Reset()

  it 'passwordReset (valid email, 200 ws response)', (done)->
    ws_Called = false
    email     = 'aaa@aaaa.com'
    using pwd_Reset_Controller,->
      @.req = { body : email: email}
      @.res =
        redirect: (target)->
          target.assert_Is '/guest/pwd-sent.html'
          ws_Called.assert_True()
          done()

      on_SendPasswordReminder = (ws_req, ws_res)->
        ws_req.body.email.assert_Is email
        ws_Called = true
        ws_res.status(200).send()

      @.password_Reset()

  it 'passwordReset(bad server)', (done)->
    req =
      body   : {}
    res =
      redirect: (target)->
        target.assert_Is '/error'
        done()
      render : (target,model)->
        model.assert_Is_Not_Undefined
        model.errorMessage?.assert_Is('TEAM Mentor is unavailable, please contact us at ')
        target.assert_Is('source/jade/guest/login-cant-connect.jade')
        done()
    options =
      config:
        tm_35_Server   : 'http://aaaaa.teammentor.net/'
        tmWebServices  : 'tmWebServices'
    using new Pwd_Reset_Controller(req,res, options),->
      @password_Reset()

  it 'password_Reset_Token (no body)', (done)->

    using pwd_Reset_Controller,->
      @.req = {}

      @.res =
        render: (jade_View,view_Model)=>
          jade_View.assert_Is @.jade_password_reset_fail
          view_Model.assert_Is { errorMessage: 'Your password should be at least 8 characters long. It should have one uppercase and one lowercase letter, a number and a special character' }
          done()

      @password_Reset_Token()

  it 'password_Reset_Token (empty body)', (done)->

    using pwd_Reset_Controller,->
      @.req = { body: {}}

      @.res =
        render: (jade_View,view_Model)=>
          jade_View.assert_Is @.jade_password_reset_fail
          view_Model.assert_Is { errorMessage: 'Your password should be at least 8 characters long. It should have one uppercase and one lowercase letter, a number and a special character' }
          done()

      @password_Reset_Token()

  it 'password_Reset_Token (valid data, {d:true ws response})', (done)->
    using pwd_Reset_Controller,->
      @.req =
        params : { username: 'demo' , token: '00000000-0000-0000-0000-000000000000'}
        body   : { password: '!!TmAdmin24**','confirm-password':'!!TmAdmin24**'}

      @.res =
        redirect: (target)=>
          target.assert_Is  @.url_password_reset_ok
          done()

      on_PasswordReset = (ws_Req, ws_Res)->
        ws_Res.send {d:true}

      @password_Reset_Token()

  it 'password_Reset_Token (valid data, {d:false ws response})', (done)->
    using pwd_Reset_Controller,->
      @.req =
        params : { username: 'demo' , token: '00000000-0000-0000-0000-000000000000'}
        body   : { password: '!!TmAdmin24**','confirm-password':'!!TmAdmin24**'}

      @.res =
        render: (jade_Page, view_Model)=>
          jade_Page.assert_Is 'source/jade/guest/pwd-reset-fail.jade'
          view_Model.assert_Is { errorMessage: 'Invalid token, perhaps it has expired' }
          done()

      on_PasswordReset = (ws_Req, ws_Res)->
        ws_Res.send {d:false}

      @password_Reset_Token()

  it 'password_Reset_Token (valid data, {null ws response})', (done)->
    using pwd_Reset_Controller,->
      @.req =
        params : { username: 'demo' , token: '00000000-0000-0000-0000-000000000000'}
        body   : { password: '!!TmAdmin24**','confirm-password':'!!TmAdmin24**'}

      @.res =
        render: (jade_Page, view_Model)=>
          jade_Page.assert_Is 'source/jade/guest/pwd-reset-fail.jade'
          view_Model.assert_Is { errorMessage: 'Invalid token, perhaps it has expired' }
          done()

      on_PasswordReset = (ws_Req, ws_Res)->
        ws_Res.send null

      @password_Reset_Token()

  it 'password_Reset(bad server)', (done)->
    req =
      params : { username: 'aaaa' , token: 'bbbb'}
      body   : { password: '!!TmAdmin24**','confirm-password':'!!TmAdmin24**'}
    res =
      redirect: (target)->
        target.assert_Is '/error'
        done()
    options =
      config:
        tm_35_Server   : 'http://aaaaa.teammentor.net/'
        tmWebServices  : 'bbbbbb'
    using new Pwd_Reset_Controller(req,res, options),->
      @password_Reset_Token()

  describe 'Check password_Reset_Token method validation',->

    password_reset_fail       = 'source/jade/guest/pwd-reset-fail.jade'
    password_reset_ok         = 'source/jade/guest/login-pwd-reset.html'

    invoke_PasswordReset = (username, token, password, confirmPassword,expected_Target, expected_Message,callback)->
      using pwd_Reset_Controller,->
        @.req =
          params : { username: username , token: token}
          body   : { password: password,'confirm-password':confirmPassword}

        @.res =
          render: (jade_Page, view_Model)=>
            jade_Page.assert_Is expected_Target
            view_Model.assert_Is { errorMessage: expected_Message }
            callback()

        @password_Reset_Token()


      #invoke_Method "password_Reset_Token",
      #  { password: password,'confirm-password': confirmPassword } ,
      #  expected_Target,
      #  callback

    text_Invalid_Token   = 'Token is invalid'
    text_Password_Match  = 'Passwords don\'t match'
    text_Password_Length = 'Password must be 8 to 256 character long'
    text_Password_Empty  = 'Password must not be empty'
    text_No_Pwd_Confirm  = 'Confirmation Password must not be empty'
    text_Bad_Password    = 'Your password should be at least 8 characters long. It should have one uppercase and one lowercase letter, a number and a special character'

    it 'password_Reset fail (no user)', (done)->
      invoke_PasswordReset null,'AAA','','',password_reset_fail, text_Invalid_Token, ->
        invoke_PasswordReset '','AAA','','',password_reset_fail, text_Invalid_Token, ->
          done()

    it 'password_Reset fail (no token)', (done)->
      invoke_PasswordReset 'user',null,'','',password_reset_fail, text_Invalid_Token, ->
        invoke_PasswordReset 'user','','','',password_reset_fail, text_Invalid_Token, ->
          done()

    it 'password_Reset fail (Passwords do not match)', (done)->
      invoke_PasswordReset 'user','token','a','b',password_reset_fail, text_Password_Match, ->
        done()

    it 'password_Reset fail (Weak Password)', (done)->
      invoke_PasswordReset 'user','token','abcdefghi','abcdefghi',password_reset_fail,text_Bad_Password,->
        done()

    it 'password_Reset fail (short Password)', (done)->
      invoke_PasswordReset 'user','token','abc','abc',password_reset_fail, text_Password_Length,->
        done()

    it 'password_Reset fail (Password not provided)', (done)->
      invoke_PasswordReset 'user','token','','',password_reset_fail, text_Password_Empty, ->
        done()

    it 'password_Reset fail (Confirmation password not provided)', (done)->
      invoke_PasswordReset 'user','token','!!Sifsj487(*&','',password_reset_fail, text_No_Pwd_Confirm, ->
        done()

  describe 'routes',->
    it 'register_Routes',->
      routes = {}
      app    =
        post: (url, target)-> routes['post:'+ url] = target
        get:  (url, target)-> routes['get:' + url] = target

      Pwd_Reset_Controller.register_Routes app
      routes.keys().assert_Is [ 'post:/user/pwd_reset', 'post:/passwordReset/:username/:token','get:/passwordReset/:username/:token'  ]
      routes['post:/user/pwd_reset'                ].source_Code().assert_Contains 'return new Pwd_Reset_Controller(req, res).password_Reset();'
      routes['post:/passwordReset/:username/:token'].source_Code().assert_Contains 'return new Pwd_Reset_Controller(req, res).password_Reset_Token();'
      routes['get:/passwordReset/:username/:token' ].source_Code().assert_Contains 'return new Pwd_Reset_Controller(req, res).password_Reset_Page();'
