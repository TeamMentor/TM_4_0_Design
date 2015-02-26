
add_Routes = (app,searchController)->
    Express_Service         = require '../services/Express-Service'
    Jade_Service            = require '../services/Jade-Service'
    Article_Controller      = require '../controllers/Article-Controller'
    Help_Controller         = require '../controllers/Help-Controller'
    Jade_Controller         = require '../controllers/Jade-Controller'
    Login_Controller        = require '../controllers/Login-Controller'
    Misc_Controller         = require '../controllers/Misc-Controller'
    Search_Controller       = require '../controllers/Search-Controller'
    Pwd_Reset_Controller    = require '../controllers/Pwd-Reset-Controller'
    User_Sign_Up_Controller = require '../controllers/User-Sign-Up-Controller'

    PoC_Controller          = require('../poc/PoC-Controller')

    #login routes
    
    app.get  '/user/login'     , (req, res)-> new Login_Controller(req, res).redirectToLoginPage()
    app.post '/user/login'     , (req, res)-> new Login_Controller(req, res).loginUser()
    app.get  '/user/logout'    , (req, res)-> new Login_Controller(req, res).logoutUser()
    app.post '/user/sign-up'   , (req, res)-> new User_Sign_Up_Controller(req, res).userSignUp()

    app.get '/index.html'                                   , (req, res)-> res.send new Jade_Service(app.config).renderJadeFile '/source/jade/guest/default.jade'
    app.get '/guest/:page.html'                             , (req, res)-> res.send new Jade_Service(app.config).renderJadeFile '/source/jade/guest/' + req.params.page + '.jade'


    Search_Controller   .register_Routes(app, searchController)
    Article_Controller  .register_Routes(app, searchController)
    Pwd_Reset_Controller.register_Routes(app                  )
    Help_Controller     .register_Routes(app                  )
    Misc_Controller     .register_Routes(app                  )
    Jade_Controller     .register_Routes(app                  )
    PoC_Controller      .register_Routes(app, searchController)

    #app.get '/passwordReset/:username/:token'               , (req, res)->  res.send new Jade_Service(app.config).renderJadeFile '/source/jade/guest/pwd-reset.jade'

    #errors 404 and 500
    app.get '/error', (req,res)-> res.status(500).render 'source/jade/guest/500.jade'
    app.get '/*'    , (req,res)-> res.status(404).render 'source/jade/guest/404.jade'

    app.use (err, req, res, next)->
      #console.error(err.stack)
      console.log "Error with request url: #{req.url} \n
                      #{err.stack.split_Lines().take(4).join('\n')}"
      #console.error(err)
      res.status(501)
         .render 'source/jade/guest/500.jade'

module.exports = add_Routes