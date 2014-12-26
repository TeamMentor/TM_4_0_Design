/*jslint node: true */
"use strict";
var request = require('request')

var users = [ { username : 'tm'   , password : 'tm'   } ,
              { username : 'user' , password : 'a'     } ,
              { username : 'roman', password : 'longpassword'     }
            ];
            
var loginPage         = 'login-Fail.jade'
var mainPage_user     = '/user/main.html'
var mainPage_no_user  = '/guest/default.html'
var loginSuccess      = 0

var Login_Controller = function(req, res) 
    {
        //var that  = this;
        
        this.users              = users;
        this.loginPage          = loginPage;
        this.mainPage_user      = mainPage_user;
        this.mainPage_no_user   = mainPage_no_user;
        this.req                = req;
        this.res                = res;          
        
        this.redirectToLoginPage = function()
            {
                this.res.redirect(this.loginPage);
            };
        this.loginUser = function() {
            if (req.body.username === '' || req.body.password === '')
                {
                    req.session.username = undefined;
                    res.redirect(loginPage);
                    return
                }
                //Temp QA logins
                for(var index in users)
                {
                    var user = users[index];
                    if (user.username === req.body.username && user.password === req.body.password)
                    {
                        req.session.username = user.username;
                        res.redirect(mainPage_user);
                        return;
                    }
                }
                var username = req.body.username
                var password = req.body.password

                //Using new API methods
                var loginUrl = 'https://tmdev01-uno.teammentor.net/Aspx_Pages/TM_WebServices.asmx/Login_Response'
                var options = {
                                method: 'post',
                                body: {username:username, password:password},
                                json: true,
                                url: loginUrl
                              };

                request(options, function(error, response, body)
                {
                    if(response.body!=null)
                    {
                        var loginResponse = response.body.d

                        if(loginResponse!= null)
                        {
                            var success = loginResponse.Login_Status
                            if (success == loginSuccess)
                            {
                                req.session.username = username
                                 res.redirect(mainPage_user)
                            }
                            else
                            {
                                console.log('not logged in...') 
                                req.session.username = undefined
                                req.errorMesage = loginResponse.Validation_Results[0].Message
                                console.log(req.errorMesage)
                                 res.render(loginPage,{errorMessage:req.errorMesage})
                            }
                        }
                    }
                });
        };
        this.logoutUser = function()
            {
                req.session.username = undefined;
                res.redirect(mainPage_no_user);
            };
        this.passwordReset = function()
            {
                var email = req.body.email

                var options = {
                                method: 'post',
                                body: {email: email},
                                json: true,
                                url: 'https://tmdev01-uno.teammentor.net/Aspx_Pages/TM_WebServices.asmx/SendPasswordReminder'
                          };
                request(options, function(error, response, body)
                {
                    if (error && error.code==="ENOTFOUND")
                    {
                        res.send('could not connect with TM Uno server');
                        return;
                    }
                    if (response.statusCode == 200)
                        res.redirect('/guest/pwd-sent.html');
                    else
                        res.send(JSON.stringify(response));

                });
            };
        this.userSignUp = function()
            {
                if (req.body.password != req.body['password-confirm'])
                {
                    res.redirect('/guest/sign-up-Fail.html');
                    return
                }

                var newUser =
                    {
                        username : req.body.username,
                        password : req.body.password,
                        email    : req.body.email
                    }
                var options = {
                    method: 'post',
                    body: {newUser: newUser},
                    json: true,
                    url: 'https://tmdev01-uno.teammentor.net/Aspx_Pages/TM_WebServices.asmx/CreateUser'
                };
                request(options, function(error, response, body)
                    {
                        if (error && error.code==="ENOTFOUND")
                        {
                            res.send('could not connect with TM Uno server');
                            return;
                        }
                        if (response.statusCode == 200)
                            if(response.body.d == '0')
                                res.redirect('/guest/sign-up-Fail.html');
                            else
                                res.redirect('/guest/sign-up-OK.html');
                        else
                            res.send(response)
                    });
                 //   res.send('user signup goes here for ' + newUser.json_pretty())
            }
    };

module.exports = Login_Controller;