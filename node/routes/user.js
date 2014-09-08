/*jslint node: true */
"use strict";

module.exports = function (app) 
{    
    var users = [ { username : 'tm'   , password : 'tm'   } ,
                  { username : 'user' , password : 'user'}
                ];
    app.post('/action/login'               ,function (req, res)  
            {                         
                for(var index in users)
                {
                    var user = users[index];
                    if (user.username === req.body.username && user.password === req.body.password)
                    {
                        res.redirect('/home/main-app-view.html');
                        //res.send('Login ok');
                        return;
                    }
                } 
        
                //res.send('Login failed');  
                res.redirect('/user/returning-user-validation.html');

                //res.redirect('/user/returning-user-forgot-password.html');
            });
};