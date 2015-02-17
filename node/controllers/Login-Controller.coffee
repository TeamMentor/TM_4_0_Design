
request = null
Config  = null

users = [ { username : 'tm'   , password : 'tm'   } ,
          { username : 'user' , password : 'a'     } ,
        ];

loginPage                  = 'source/jade/guest/login-Fail.jade'
mainPage_user              = '/user/main.html'
mainPage_no_user           = '/guest/default.html'
password_reset_fail        = 'source/jade/guest/pwd-reset-fail.jade'
password_reset_ok          = '/guest/login-pwd-reset.html'
blank_credentials_message  = 'Invalid Username or Password'
loginSuccess        = 0

class Login_Controller
  constructor: (req, res)->

    request = require('request')
    Config  = require('../misc/Config')

    @.users              = users
    @.req                = req || {}
    @.res                = res || {}
    @.config             = new Config();
    @.webServices        = @.config.tm_35_Server + @.config.tmWebServices
        
  redirectToLoginPage:  ()=>
    @.res.redirect(loginPage)

  loginUser: ()=>
    userViewModel ={username: @.req.body.username,password:'',errorMessage:''}

    if (@.req.body.username == '' or @.req.body.password == '')
        @.req.session.username = undefined;
        userViewModel.errorMessage=blank_credentials_message
        @.res.render(loginPage,{viewModel:userViewModel})
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
                  userViewModel.errorMessage  = loginResponse.Validation_Results.first().Message
              else
                  userViewModel.errorMessage  = loginResponse?.Simple_Error_Message
              @.res.render(loginPage,{viewModel:userViewModel})

  logoutUser: ()=>
    @.req.session.username = undefined
    @.res.redirect(mainPage_no_user)


module.exports = Login_Controller
