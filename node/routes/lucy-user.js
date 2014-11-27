/*jslint node: true */
"use strict";

module.exports = function (app)
{
    var loginPage         = '/getting-started/index';
    var mainPage_user     = '/home/main-app-view';
    var mainPage_no_user  = '/landing-pages/index';

    var users = [ { username : 'tm'   , password : 'tm'   } ,
                  { username : 'user' , password : ''     } ,
                  { username : 'a'    , password : ''     }
                ];
    app.get('/getting-started/index'  , function (req, res)
            {
                res.redirect(loginPage);
            });
    app.post('/home/main-app-view' , function (req, res)
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
            });
    app.get ('logout' , function (req, res)
            {
                req.session.username = undefined;
                res.redirect(mainPage_no_user);
            });
};