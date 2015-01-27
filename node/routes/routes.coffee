
Express_Service     = require('../services/Express-Service')
Jade_Service        = require('../services/Jade-Service')

Help_Controller     = require('../controllers/Help-Controller')
Jade_Controller     = require('../controllers/Jade-Controller')
Login_Controller    = require('../controllers/Login-Controller')
Library_Controller  = require('../controllers/Library-Controller')
Search_Controller   = require('../controllers/Search-Controller')



add_Routes = (app,searchController)->
    #Route for CSP (Content Security Policy) violations to post

    #app.post '/csp' , (req, res)-> console.log req.body #res.status(200)
    
    #login routes (and temporarily also user-sign-up)

    app.get  '/user/login'     , (req, res)-> new Login_Controller(req, res).redirectToLoginPage()
    app.post '/user/login'     , (req, res)-> new Login_Controller(req, res).loginUser()
    app.get  '/user/logout'    , (req, res)-> new Login_Controller(req, res).logoutUser()
    app.post '/user/pwd_reset' , (req, res)-> new Login_Controller(req, res).passwordReset()
    app.post '/user/sign-up'   , (req, res)-> new Login_Controller(req, res).userSignUp()
    app.post '/passwordReset/:username/:token'   , (req, res)-> new Login_Controller(req, res).passwordResetToken()

    
    #library routes
    Library_Controller.registerRoutes(app)
    
    #search routes
    Search_Controller.registerRoutes(app, searchController);
    
    #help routes
    
    app.get '/help/:page*' , (req, res)-> new Help_Controller(req, res).renderPage()
    app.get '/Image/:name' , (req, res)-> new Help_Controller(req, res).redirectImagesToGitHub()

    # jade (pre-compiled) pages (these have to be the last set of routes)

    #app.get '/'                                             , (req, res)-> res.send new Jade_Service(app.config).renderJadeFile '/source/jade/guest/default.jade'
    app.get '/index.html'                                   , (req, res)-> res.send new Jade_Service(app.config).renderJadeFile '/source/jade/guest/default.jade'
    app.get '/guest/:page.html'                             , (req, res)-> res.send new Jade_Service(app.config).renderJadeFile '/source/jade/guest/' + req.params.page + '.jade'

    # password reset
    app.get '/passwordReset/:username/:token'               , (req, res)->  res.send new Jade_Service(app.config).renderJadeFile '/source/jade/guest/pwd-reset.jade'
    #Jade render routes

    Jade_Controller.registerRoutes(app)
    #Redirect to Jade pages
    #app.get '/deploy/html/:area/:page.html'                 , (req, res)-> res.redirect('/' + req.params.area + '/' + req.params.page + '.html')
    

module.exports = add_Routes