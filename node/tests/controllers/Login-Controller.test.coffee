Login_Controller = require('../../controllers/Login-Controller')

describe "controllers | test-Login-Controller |", ->

  @.timeout(3500)

  it "loginUser (empty username, password)", (done)->

    req =
          body   : { username : '' , password : '' }
          session: {}
    res =
          redirect: (target)->
            target.assert_Is('/guest/login-Fail.html')
            done()
    loginController = new Login_Controller(req,res)
    loginController.loginUser()

  it "loginUser (valid username, password)", (done)->

    req =
      body   : { username : 'abc' , password : '123' }
      session: {}
    res =
      redirect: (target)->
        target.assert_Is('/guest/login-Fail.html')
        done()
    loginController = new Login_Controller(req,res)
    loginController.loginUser()

  it "loginUser (good username, password)", (done)->

    req =
      body   : { username : 'user' , password : 'a' }
      session: {}
    res =
      redirect: (target)->
        target.assert_Is('/user/main.html')
        done()
    loginController = new Login_Controller(req,res)
    loginController.loginUser()

  it 'logoutUser', (done)->
    req =
      session: {}
    res =
      redirect: (target)->
        target.assert_Is('/guest/default.html')
        done()
    loginController = new Login_Controller(req,res)
    loginController.logoutUser()

  it 'passwordReset', (done)->
    req =
      body   : { email : 'aaaaaa@teammentor.net'  }
      session: {}
    res =
      redirect: (target)->
        target.assert_Is('/guest/pwd-sent.html')
        done()
    loginController = new Login_Controller(req,res)
    loginController.passwordReset()

  it 'userSignUp', (done)->
    req =
      body   : { username : 'user' , password : 'a' , email:'aaaaa@teammentor.net'}
      session: {}
    res =
      redirect: (target)->
        target.assert_Is('/guest/sign-up-Fail.html')
        done()
    loginController = new Login_Controller(req,res)
    loginController.userSignUp()
