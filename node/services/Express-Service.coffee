Config          = require('../misc/Config')
Jade_Service    = require('../services/Jade-Service')
Express_Session = require('../misc/Express-Session')
bodyParser      = require('body-parser')
session         = require('express-session')
path            = require("path")
express         = require('express')
helmet          = require('helmet')

class Express_Service
  constructor: ()->
    @.app         = express()
    @loginEnabled = true;
    @.app.port    = process.env.PORT || 1337;
    @.expressSession = null

  setup: ()=>
    @set_BodyParser()
    @set_Config()
    @set_Static_Route()
    @add_Session()      # for now not using the async version of add_Session
    @set_Views_Path()
    @set_CSP_Headers()
    @
  add_Session: (sessionFile)=>

    @.expressSession = new Express_Session({ filename: sessionFile || './.tmCache/_sessionData' ,session:session})
    @.app.use session({ secret: '1234567890', key: 'tm-session'
                        ,saveUninitialized: true , resave: true
                        , cookie: { path: '/' , httpOnly: true , maxAge: 365 * 24 * 3600 * 1000 }
                        , store: @.expressSession })


  set_BodyParser: ()=>
    @.app.use(bodyParser.json()                        );     # to support JSON-encoded bodies
    @.app.use(bodyParser.urlencoded({ extended: true }));     # to support URL-encoded bodies

  set_Config:()=>
    @.app.config = new Config(null, false);

  set_Static_Route:()=>
    @app.use(express['static'](process.cwd()));

  set_Views_Path :()=>
    @.app.set('views', path.join(__dirname,'../../'))

  set_CSP_Headers: ()=>
    @.app.use(helmet.csp({
      defaultSrc: [
        "'self'",
        "'unsafe-inline'",
      ]
      reportUri: '/csp'
    }));

  map_Route: (file)=>
    require(file)(@.app,@);
    @

  start:()=>
    if process.mainModule.filename.not_Contains('node_modules/mocha/bin/_mocha')
      console.log("[Running locally or in Azure] Starting 'TM Jade' Poc on port " + @app.port)
      @app.server = @app.listen(@app.port)

  checkAuth: (req, res, next, config)=>
    if (@.loginEnabled and req and req.session and !req.session.username)
      res.status(403)
         .send(new Jade_Service(config).renderJadeFile('/source/jade/guest/login-required.jade'))
    else
      next()

  mappedAuth: (req)->
    data = {};
    if(req && req.session)
      data =  {
        username  : req.session.username,
        loggedIn  : (req.session.username != undefined)
      }
    return data

module.exports = Express_Service