/*jslint node: true */
"use strict";
var request = require('request')

var users = [ { username : 'tm'   , password : 'tm'   } ,
              { username : 'user' , password : 'a'     } ,
              { username : 'roman', password : 'longpassword'     }
            ];
            
var loginPage         = '/guest/login-Fail.html'
var mainPage_user     = '/user/main.html'
var mainPage_no_user  = '/guest/default.html'

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


                //major hack for demo (this needs to be done by consuming the GraphDB TeamMentor-Service)
                var loginUrl = 'https://tmdev01-uno.teammentor.net/rest/login/' + username + '/' + password;

                request(loginUrl, function(error, response, body)
                    {
                        if (error || body.indexOf('00000000-0000-0000-0000-00000000000') > -1 || body.indexOf('Endpoint not found.')>-1 )
                        {
                            req.session.username = undefined;
                            res.redirect(loginPage);
                        }
                        else
                        {
                            req.session.username = username;
                            res.redirect(mainPage_user);
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