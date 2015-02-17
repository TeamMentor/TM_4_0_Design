Login_Controller        = require('../../controllers/Login-Controller')
User_Sign_Up_Controller = require('../../controllers/User-Sign-Up-Controller')

describe "| controllers | Login-Controller.test |", ->

  #helper methods
  loginPage                 = 'source/jade/guest/login-Fail.jade'
  mainPage_user             = '/user/main.html'
  mainPage_no_user          = '/guest/default.html'
  password_sent             = '/guest/pwd-sent.html'
  signUp_fail               = "source/jade/guest/sign-up-Fail.jade"
  signUp_Ok                 = '/guest/sign-up-OK.html'
  password_reset_fail       = 'source/jade/guest/pwd-reset-fail.jade'
  password_reset_ok         = 'source/jade/guest/login-pwd-reset.html'
  blank_credentials_message = 'Invalid Username or Password'


  #describe
  describe 'login user', ->

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
      loginController = new Login_Controller(req, res)
      loginController[method]()

    invoke_LoginUser = (username, password, expected_Target, callback)->
      invoke_Method "loginUser",
                    { username : username , password : password } ,
                    expected_Target,
                    callback

    @.timeout(10000)

    it 'constructor', ->
      using new Login_Controller,->
        @.users           .assert_Is_Array().second().username.assert_Is 'user'
        @.req             .assert_Is {}
        @.res             .assert_Is {}

      using new Login_Controller('req', 'res'),->
        @.req             .assert_Is 'req'
        @.res             .assert_Is 'res'

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

    it "LoginUser(undefined Login_Status using existential operator)", (done)->
      invoke_LoginUser undefined ,undefined , loginPage, done

    it 'logoutUser', (done)->
      invoke_Method "logoutUser", {} ,mainPage_no_user,done


    it 'redirectToLoginPage', (done)->
      invoke_Method "redirectToLoginPage", { } ,loginPage,done

    it 'Invalid Username or Password (missing username)',(done)->
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


    it 'Invalid Username or Password (missing password)',(done)->
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

    it 'Invalid Username or Password (missing both username and password)',(done)->
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

  describe 'user sign-up', ->
    @.timeout(10000)

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
      using new User_Sign_Up_Controller(req, res), ->
        @[method]()

    invoke_UserSignUp = (username, password, email, expected_Target, callback)->
      invoke_Method "userSignUp",
        { username: username , password: password,'confirm-password':password , email: email } ,
        expected_Target,
        callback

    invoke_Login_Method = (method, body, expected_Target, callback)->
      req =
        session: {}
        url    : '/passwordReset/temp/00000000-0000-0000-0000-000000000000'
        body   : body

      res =
        redirect: (target)->
          target.assert_Is(expected_Target)
          callback()

      loginController = new Login_Controller(req, res)
      loginController[method]()

    invoke_LoginUser = (username, password, expected_Target, callback)->
      invoke_Login_Method "loginUser",
                          { username : username , password : password } ,
                          expected_Target,
                          callback




    it 'userSignUp (bad values)', (done)->
      invoke_UserSignUp '','aa','aa@teammentor.net', signUp_fail, ->                      #empty username
        invoke_UserSignUp 'aaa','','aa@teammentor.net', signUp_fail, ->                   #empty password
          invoke_UserSignUp 'aa','aa','', signUp_fail,->                                  #empty email
            invoke_UserSignUp 'user','weakpwd','aa@teammentor.net', signUp_fail,->        #weak password
              done()



    it 'userSignUp (good values)', (done)->
      user = "tm_ut_".add_5_Random_Letters()
      pwd  = "**tm**pwd**"
      email = "#{user}@teammentor.net"

      invoke_UserSignUp user,pwd,email,signUp_Ok,->
          invoke_LoginUser user,pwd,mainPage_user,done

    it 'userSignUp (pwd dont match)', (done)->
      req =
        body   : { password:'aa' , 'password-confirm':'bb'}
      res =
        render : (target) ->
          target.assert_Contains(signUp_fail)
          done()

      using new User_Sign_Up_Controller(req,res),->
        @userSignUp()

    it 'userSignUp (error handling)', (done)->
      req =
        body   : { password:'aa' , 'confirm-password':'aa'}
      res =
        send: (data)->
          data.assert_Is('could not connect with TM Uno server')
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
        @.userSignUp()


    it 'Login form persist HTML form fields on error (Wrong Password)',(done)->
      newUsername         ='tm'
      newPassword         ='aaa'.add_5_Letters()

      #render contains the file to render and the view model object
      render = (html,model)->
        model.viewModel.username.assert_Is(newUsername)
        model.viewModel.password.assert_Is('')
        model.viewModel.errorMessage.assert_Is('Wrong Password')
        done()
      req = body:{username:newUsername,password:newPassword}, session:''
      res = {render: render}

      using new Login_Controller(req, res), ->
        @.loginUser()

