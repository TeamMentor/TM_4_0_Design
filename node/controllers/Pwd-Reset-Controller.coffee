request = null
Config  = null

class Pwd_Reset_Controller

  constructor: (req, res, options)->

    request = require('request')
    Config  = require('../misc/Config')

    @.options                     = options || {}
    @.req                         = req
    @.res                         = res
    @.config                      = @.options.config || new Config()
    @.request_Timeout             = @.options.request_Timeout || 1500
    @.webServices                 = @.config.tm_35_Server + @.config.tmWebServices
    @.jade_password_reset_fail    = 'source/jade/guest/pwd-reset-fail.jade'
    @.url_password_reset_ok       = '/guest/login-pwd-reset.html'
    @.url_password_sent           = '/guest/pwd-sent.html'
    @.url_WS_SendPasswordReminder = @.webServices + '/SendPasswordReminder'
    @.url_WS_PasswordReset        = @.webServices + '/PasswordReset'
    @.url_error_page              = '/error'

  passwordReset: ()=>

    email = @.req?.body?.email

    options = {
                    method : 'post'
                    body   : {email: email}
                    json   : true
                    url    : @.url_WS_SendPasswordReminder
                    timeout: @.request_Timeout
              }
    request options, (error, response, body)=>
      if ((not error) and response?.statusCode == 200)
          @.res.redirect(@.url_password_sent);
      else
          @.res.redirect(@.url_error_page );


  passwordResetToken : ()=>

    username = @.req.params?.username
    token    = @.req.params?.token

    passwordStrengthRegularExpression =///(
        (?=.*\d)            # at least 1 digit
        (?=.*[A-Z])         # at least 1 upper case letter
        (?=.*[a-z])         # at least 1 lower case letter
        (?=.*\W)            # at least 1 special character
        .                   # match any with previous validations
        {8,256}             # 8 to 256 characters
       )///

    #Validating token
    if (token == null or username == null or username is '' or token is '')
      @res.render(@.jade_password_reset_fail, {errorMessage: 'Token is invalid'})
      return

    #Password not provided
    if (@.req.body?.password?.length is 0)
      @res.render(@.jade_password_reset_fail, {errorMessage: 'Password must not be empty'})
      return

    #Confirmation password not provided
    if (@.req.body?['confirm-password']?.length is 0)
      @res.render(@.jade_password_reset_fail, {errorMessage: 'Confirmation Password must not be empty'})
      return

    #Passwords must match
    if (@.req.body?.password != @.req.body?['confirm-password'])
      @res.render(@.jade_password_reset_fail, {errorMessage: 'Passwords don\'t match'})
      return
    #length check
    if (@.req.body?.password?.length < 8 || @.req.body?.password?.length > 256 )
      @res.render(@.jade_password_reset_fail, {errorMessage: 'Password must be 8 to 256 character long'})
      return

    #Complexity
    if (!@.req.body?.password?.match(passwordStrengthRegularExpression))
      @.res.render(@.jade_password_reset_fail, {errorMessage: 'Your password should be at least 8 characters long. It should have one uppercase and one lowercase letter, a number and a special character'})
      return

    #request options
    options = {
                   method: 'post'
                   body  : {userName: username,token: token, newPassword:@.req.body.password}
                   json  : true
                   url   : @.url_WS_PasswordReset
              }

    request options, (error, response, body)=>
      if (not error) and response.statusCode is 200
        if response?.body?.d
          @res.redirect(@.url_password_reset_ok )
        else
          @res.render(@.jade_password_reset_fail,{errorMessage: 'Invalid token, perhaps it has expired'})
      else
        @res.redirect(@.url_error_page)

Pwd_Reset_Controller.register_Routes =  (app)=>

  app.post '/user/pwd_reset'                  , (req, res)-> new Pwd_Reset_Controller(req, res).passwordReset()
  app.post '/passwordReset/:username/:token'  , (req, res)-> new Pwd_Reset_Controller(req, res).passwordResetToken()

module.exports = Pwd_Reset_Controller