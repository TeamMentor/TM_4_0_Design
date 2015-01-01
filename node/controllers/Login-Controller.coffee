request = require('request')

users = [ { username : 'tm'   , password : 'tm'   } ,
          { username : 'user' , password : 'a'     } ,
        ];
            
loginPage         = '/guest/login-Fail.html'
mainPage_user     = '/user/main.html'
mainPage_no_user  = '/guest/default.html'
password_sent     = '/guest/pwd-sent.html'
signUp_fail       = '/guest/sign-up-Fail.html'
signUp_Ok         = '/guest/sign-up-OK.html'

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
    loginUrl = 'https://tmdev01-uno.teammentor.net/rest/login/' + username + '/' + password;

    request loginUrl, (error, response, body)=>
      if (error or body.indexOf('00000000-0000-0000-0000-00000000000') > -1 or body.indexOf('Endpoint not found.') >-1 )
          @.req.session.username = undefined
          @.res.redirect(loginPage)
      else
          @.req.session.username = username
          @.res.redirect(mainPage_user)

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
    if (@.req.body.password != @.req.body['password-confirm'])
        @.res.redirect(signUp_fail); #
        return                       #

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
                url: @.webServices + '/CreateUser'
              };

    request options, (error, response, body)=>
      if (error and error.code=="ENOTFOUND")
          @.res.send('could not connect with TM Uno server')
          return

      if(response.body.d is 0)
          @.res.redirect(signUp_fail)
      else
          @.res.redirect(signUp_Ok)

module.exports = Login_Controller;