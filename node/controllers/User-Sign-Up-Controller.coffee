
signUp_fail = 'source/jade/guest/sign-up-Fail.jade'
signUp_Ok   = 'source/jade/guest/sign-up-OK.html'
request     = null
Config      = null

class User_Sign_Up_Controller

  constructor: (req, res)->

    request = require('request')
    Config  = require('../misc/Config')

    @.req                = req || {}
    @.res                = res || {}
    @.config             = new Config();
    @.webServices        = @.config.tm_35_Server + @.config.tmWebServices

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
        @.res.send('Could not connect with TM 3.5 server')
        return

      if (error or response.body is null or response.statusCode isnt 200)
        @.res.send('Bad response received from TM 3.5 server')
        return

      signUpResponse = response.body?.d

      if (not signUpResponse) or (not signUpResponse.Validation_Results)
        @.res.send('Bad data received from TM 3.5 server')
        return

      message = ''

      #log signUpResponse

      if (signUpResponse.Signup_Status is 0)
        @res.redirect('/guest/sign-up-OK.html')
        return
      if (signUpResponse.Validation_Results.empty())
        message = signUpResponse.Simple_Error_Message || 'An error occurred'
      else
        message = signUpResponse.Validation_Results.first().Message
      userViewModel.errorMessage = message
      @res.render(signUp_fail, {viewModel:userViewModel})



module.exports = User_Sign_Up_Controller