/*jslint node: true */
"use strict";

module.exports = function (app) 
{    
    var users = [ { username : 'tm'   , password : 'tm'   } ,
                  { username : 'user' , password : 'user'}
                ];
    app.post('/user/login'               ,function (req, res)  
            {                     
                for(var index in users)
                {
                    var user = users[index];
                    if (user.username === req.body.username && user.password === req.body.password)
                    {
                        req.session.username = user.username;
                        res.redirect('/home/main-app-view.html');                        
                        return;
                    }
                }                
                req.session.username = undefined;
                res.redirect('/user/login/returning-user-validation.html');
            });
    app.get ('/user/logout'               ,function (req, res)  
            {
                req.session.username = undefined;
                res.redirect('/landing-pages/index.html');
            });
};