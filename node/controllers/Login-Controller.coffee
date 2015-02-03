request = require('request')
Config        = require('../misc/Config')

users = [ { username : 'tm'   , password : 'tm'   } ,
          { username : 'user' , password : 'a'     } ,
        ];
            
loginPage           = 'source/jade/guest/login-Fail.jade'
mainPage_user       = '/user/main.html'
mainPage_no_user    = '/guest/default.html'
password_sent       = '/guest/pwd-sent.html'
signUp_fail         = 'source/jade/guest/sign-up-Fail.jade'
signUp_Ok           = 'source/jade/guest/sign-up-OK.html'
password_reset_fail = 'source/jade/guest/pwd-reset-fail.jade'
password_reset_ok   = '/guest/login-pwd-reset.html'
loginSuccess        = 0

class Login_Controller
  constructor: (req, res)->
    @.users              = users
    @.req                = req || {}
    @.res                = res || {}
    @.config             = new Config();
    @.webServices        = @.config.tm_35_Server + @.config.tmWebServices
        
  redirectToLoginPage:  ()=>
    @.res.redirect(loginPage)

  loginUser: ()=>
    if (@.req.body.username == '' or @.req.body.password == '')
        @.req.session.username = undefined;
        @.res.redirect(loginPage);
        return

    #Temp QA logins
    for user in @.users
      if (user.username == @.req.body.username && user.password == @.req.body.password)
        @.req.session.username = user.username;
        @.res.redirect(mainPage_user);
        return;

    username = @.req.body.username
    password = @.req.body.password

    options = {
                  method: 'post',
                  body: {username:username, password:password},
                  json: true,
                  url: @.webServices + '/Login_Response'
    }
    request options, (error, response, body)=>

      if (response.body !=null && response.body.d !=null)

          loginResponse = response?.body?.d
          success = loginResponse?.Login_Status
          if (success == loginSuccess)
              @.req.session.username = username
              @.res.redirect(mainPage_user)
          else
              @.req.session.username = undefined

              if (loginResponse?.Validation_Results !=null && loginResponse?.Validation_Results?.not_Empty())
                  @.req.errorMessage  = loginResponse.Validation_Results.first().Message
              else
                  @.req.errorMessage  = loginResponse?.Simple_Error_Message
              @.res.render(loginPage,{errorMessage:@.req.errorMessage})

  logoutUser: ()=>
    @.req.session.username = undefined
    @.res.redirect(mainPage_no_user)


  passwordReset: ()=>
    email = @.req.body.email

    options = {
                    method: 'post'
                    body: {email: email}
                    json: true
                    url: @.webServices + '/SendPasswordReminder'
              }

    request options, (error, response, body)=>
        if (error and error.code=="ENOTFOUND")
            @.res.send('could not connect with TM Uno server');
            return;
        if (response.statusCode == 200)
            @.res.redirect(password_sent);
        else
            @.res.send(JSON.stringify(response));

  passwordResetToken : ()=>
    #Parsing URL
    url = @.req?.url?.split('/')
    username = url[2]?.toString()
    token    = url[3]?.toString()

    passwordStrengthRegularExpression =///(
        (?=.*\d)            # at least 1 digit
        (?=.*[A-Z])         # at least 1 upper case letter
        (?=.*[a-z])         # at least 1 lower case letter
        (?=.*\W)            # at least 1 special character
        .                   # match any with previous validations
        {8,256}             # 8 to 256 characters
       )///

    #Validating token
    if (token == null || username == null )
      @res.render(password_reset_fail, {errorMessage: 'Token is invalid'})
      return

    #Password not provided
    if (@.req.body.password.length==0)
      @res.render(password_reset_fail, {errorMessage: 'Password must not be empty'})
      return

    #Confirmation password not provided
    if (@.req.body['confirm-password'].length==0)
      @res.render(password_reset_fail, {errorMessage: 'Confirmation Password must not be empty'})
      return

    #Passwords must match
    if (@.req.body.password != @.req.body['confirm-password'])
      @res.render(password_reset_fail, {errorMessage: 'Passwords don\'t match'})
      return
    #length check
    if (@.req.body.password.length < 8 || @.req.body.password.length>256 )
      @res.render(password_reset_fail, {errorMessage: 'Password must be 8 to 256 character long'})
      return

    #Complexity
    if (!@.req.body.password.match(passwordStrengthRegularExpression))
      @res.render(password_reset_fail, {errorMessage: 'Your password should be at least 8 characters long. It should have one uppercase and one lowercase letter, a number and a special character'})
      return

    #request options
    options = {
                   method: 'post'
                   body: {userName: username,token: token,newPassword:@.req.body.password}
                   json: true
                   url: @.webServices + '/PasswordReset'
              }

    request options, (error, response, body)=>
      if (error and error.code=="ENOTFOUND")
        @.res.send('could not connect with TM Uno server');
        return;

      if (response.statusCode == 200)
        result = response?.body.d;

        if(result)
          @res.redirect(password_reset_ok)
          return;
        else
          @res.render(password_reset_fail,{errorMessage: 'Invalid token, perhaps it has expired'})
          return;

      @res.render(password_reset_fail, {errorMessage: 'Error occurred.'})


  userSignUp: ()=>
    if (@.req.body.password != @.req.body['confirm-password'])
        @res.render(signUp_fail, {errorMessage: 'Passwords don\'t match'})
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
      if (error and error.code=="ENOTFOUND")
        @.res.send('could not connect with TM Uno server')
        return

      if (response.body!=null && response.statusCode == 200)
        signUpResponse = response.body.d
        message= ''

        if (signUpResponse.Signup_Status!=0)
          if (signUpResponse.Validation_Results!=null && signUpResponse.Validation_Results.not_Empty())
              message = signUpResponse.Validation_Results.first().Message
          else
              message = signUpResponse.Simple_Error_Message
          @res.render(signUp_fail, {errorMessage: message})
        else
          @res.redirect('/guest/sign-up-OK.html')

module.exports = Login_Controller;
