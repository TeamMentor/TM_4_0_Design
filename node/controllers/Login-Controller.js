/*jslint node: true */
"use strict";

var users = [ { username : 'tm'   , password : 'tm'   } ,
              { username : 'user' , password : ''     } ,
              { username : 'a'    , password : ''     }
            ];
            
var loginPage         = '/user/login/returning-user-validation.html';
var mainPage_user     = '/home/main-app-view.html';
var mainPage_no_user  = '/landing-pages/index.html';                

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
        
        this.loginUser = function()
            {
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
                req.session.username = undefined;
                res.redirect(loginPage);
            };  
        this.logoutUser = function()
            {
                req.session.username = undefined;
                res.redirect(mainPage_no_user);
            };        
    };

module.exports = Login_Controller;