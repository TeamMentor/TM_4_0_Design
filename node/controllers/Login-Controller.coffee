request = require('request')

users = [ { username : 'tm'   , password : 'tm'   } ,
          { username : 'user' , password : 'a'     } ,
        ];
            
loginPage         = 'source/jade/guest/login-Fail.jade'
mainPage_user     = '/user/main.html'
mainPage_no_user  = '/guest/default.html'
password_sent     = '/guest/pwd-sent.html'
signUp_fail       = 'source/jade/guest/sign-up-Fail.jade'
signUp_Ok         = 'source/jade/guest/sign-up-OK.html'
loginSuccess      = 0

class Login_Controller
  constructor: (req, res)->
    @.users              = users
    @.req                = req || {}
    @.res                = res || {}
    @.webServices        = 'https://tmdev01-uno.teammentor.net/Aspx_Pages/TM_WebServices.asmx'
        
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

    #major hack for demo (this needs to be done by consuming the GraphDB TeamMentor-Service)
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