
signUp_fail             = 'source/jade/guest/sign-up-Fail.jade'
signUpPage_Unavailable  = 'source/jade/guest/sign-up-cant-connect.jade'
signUp_Ok               = 'source/jade/guest/sign-up-OK.html'
errorMessage            = "TEAM Mentor is unavailable, please contact us at "
request                 = null
Config                  = null
Analytics_Service       = null

class User_Sign_Up_Controller

  constructor: (req, res)->
    request              = require('request')
    Config               = require('../misc/Config')
    Login_Controller     = require('../controllers/Login-Controller')
    Analytics_Service    = require('../services/Analytics-Service')
    @.req                = req || {}
    @.res                = res || {}
    @.config             = new Config();
    @.webServices        = @.config.tm_35_Server + @.config.tmWebServices
    @.login              = new Login_Controller(req,res)
    @.analyticsService   = new Analytics_Service(@.req, @.res)

  userSignUp: ()=>
    userViewModel =
                    {
                        username        : @.req.body.username,
                        password        : @.req.body.password,
                        confirmpassword : @.req.body['confirm-password']
                        email           : @.req.body.email
                        errorMessage    :''
                    }

    if (@.req.body.password != @.req.body['confirm-password'])
        userViewModel.errorMessage = 'Passwords don\'t match'
        @res.render(signUp_fail,viewModel: userViewModel)
        return

    newUser =
              {
                  username : @.req.body.username,
                  password : @.req.body.password,
                  email    : @.req.body.email
              }
    options = {
                method: 'post',
                body: {newUser: newUser},
                json: true,
                url: @.webServices + '/CreateUser_Response'
              };

    request options, (error, response, body)=>
      if (error and error.code is "ENOTFOUND")
        #[QA] ADD ISSUE: Refactor this to show TM 500 error message
        logger?.info ('Could not connect with TM 3.5 server')
        userViewModel.errorMessage =errorMessage
        return @.res.render signUpPage_Unavailable, {viewModel:userViewModel}

      if (error or response.body is null or response.statusCode isnt 200)
        logger?.info ('Bad response received from TM 3.5 server')
        userViewModel.errorMessage =errorMessage
        return @.res.render signUpPage_Unavailable, {viewModel:userViewModel}


      signUpResponse = response.body?.d

      if (not signUpResponse) or (not signUpResponse.Validation_Results)
        logger?.info ('Bad data received from TM 3.5 server')
        return @.res.render signUpPage_Unavailable, {viewModel: errorMessage : 'An error occurred' }

      message = ''

      if (signUpResponse.Signup_Status is 0)
        @.analyticsService.track('','User Account',"Signup Success #{@.req.body.username}")
        return @.login.loginUser()

      if (signUpResponse.Validation_Results.empty())
        message = signUpResponse.Simple_Error_Message || 'An error occurred'
      else
        message = signUpResponse.Validation_Results.first().Message
      userViewModel.errorMessage = message
      @.analyticsService.track('','User Account',"Signup Failed #{@.req.body.username}")
      @res.render(signUp_fail, {viewModel:userViewModel})


module.exports = User_Sign_Up_Controller