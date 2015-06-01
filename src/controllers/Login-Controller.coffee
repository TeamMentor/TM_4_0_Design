
request    = null
Config     = null
analytics_Service = null

loginPage                  = 'source/jade/guest/login-Fail.jade'
loginPage_Unavailable      = 'source/jade/guest/login-cant-connect.jade'
guestPage_403              = 'source/jade/guest/403.jade'
mainPage_user              = '/user/main.html'
mainPage_no_user           = '/guest/default.html'
password_reset_fail        = 'source/jade/guest/pwd-reset-fail.jade'
password_reset_ok          = '/guest/login-pwd-reset.html'
blank_credentials_message  = 'Invalid Username or Password'
loginSuccess               = 0
errorMessage               = "TEAM Mentor is unavailable, please contact us at "

class Login_Controller
  constructor: (req, res)->

    request      = require('request')
    Config       = require('../misc/Config')
    analytics_Service   = require('../services/Analytics-Service')

    #@.users              = users
    @.req                = req || {}
    @.res                = res || {}
    @.config             = new Config();
    @.webServices        = @.config.tm_35_Server + @.config.tmWebServices
    @.analyticsService   = new analytics_Service(@.req, @.res)
        
  redirectToLoginPage:  ()=>
    @.res.redirect(loginPage)

  loginUser: ()=>
    userViewModel ={username: @.req.body.username,password:'',errorMessage:''}

    if (@.req.body.username == '' or @.req.body.password == '')
        @.req.session.username = undefined;
        userViewModel.errorMessage=blank_credentials_message
        @.res.render(loginPage,{viewModel:userViewModel})
        return

    username = @.req.body.username
    password = @.req.body.password

    options =
              method: 'post',
              body: {username:username, password:password},
              json: true,
              url: @.webServices + '/Login_Response'

    request options, (error, response, body)=>
      if error
        logger?.info ('Could not connect with TM 3.5 server')
        console.log (errorMessage)
        userViewModel.errorMessage = errorMessage
        userViewModel.username =''
        userViewModel.password=''
        return @.res.render loginPage_Unavailable, {viewModel:userViewModel }

      if not (response?.body?.d)
        logger?.info ('Could not connect with TM 3.5 server')
        userViewModel.errorMessage = errorMessage
        userViewModel.username =''
        userViewModel.password=''
        return @.res.render loginPage_Unavailable, {viewModel:userViewModel }

      loginResponse = response.body.d
      success = loginResponse?.Login_Status
      if (success == loginSuccess)
        @.analyticsService.track('','User Account','Login Success')
        @.req.session.username = username
        redirectUrl =@.req.session.redirectUrl
        if(redirectUrl? && redirectUrl.is_Local_Url())
          delete @.req.session.redirectUrl
          @.res.redirect(redirectUrl)
        else
          @.res.redirect(mainPage_user)
      else
          @.req.session.username = undefined
          @.analyticsService.track('','User Account','Login Failed')
          if (loginResponse?.Validation_Results !=null && loginResponse?.Validation_Results?.not_Empty())
              userViewModel.errorMessage  = loginResponse.Validation_Results.first().Message
          else
              userViewModel.errorMessage  = loginResponse?.Simple_Error_Message
          @.res.render(loginPage,{viewModel:userViewModel})

  logoutUser: ()=>
    @.req.session.username = undefined
    @.res.redirect(mainPage_no_user)

  tm_SSO: ()=>
    username = @.req.query.username || @.req.query.userName
    token    = @.req.query.requestToken
    format   = @.req.query.format
    if username and token
      server = @.config.tm_35_Server
      path   = @.req.route.path.substring(1)
      url = "#{server}#{path}?username=#{username}&requestToken=#{token}"

      if (format?)
        url = url + "&format=#{format}"
      options =
        url: url
        followRedirect: false

      request options,(error, response, data)=>
        if response.headers?.location is '/teammentor'
          @.req.session.username = username
          return @.res.redirect '/'
        else
          if (response.headers?['content-type']=='image/gif')
            @.req.session.username = username
            gifImage = new Buffer('R0lGODlhAQABAPcAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAACH5BAEAAP8ALAAAAAABAAEAAAgEAP8FBAA7', 'base64')
            @.res.writeHead(200, {'Content-Type': 'image/gif' });
            @.res.write(gifImage)
            return @.res.end()
        @.res.render guestPage_403
    else
      @.res.render guestPage_403


module.exports = Login_Controller
