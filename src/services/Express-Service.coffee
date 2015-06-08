Config          = null
Jade_Service    = null
Session_Service = null
Logging_Service = null
bodyParser      = null

path            = null
express         = null
helmet          = null

class Express_Service

  dependencies: ()->
    Config           = require '../misc/Config'
    Jade_Service     = require '../services/Jade-Service'
    Session_Service  = require '../services/Session-Service'
    Logging_Service  = require '../services/Logging-Service'
    bodyParser       = require 'body-parser'
    path             = require "path"
    express          = require 'express'
    helmet           = require 'helmet'

  constructor: (options)->
    @.dependencies()
    @.options         = options || { logging_Enabled: true}
    @.app             = express()
    @loginEnabled     = true;
    @.app.port        = @.options.port || process.env.PORT || 1337;
    @.session_Service = null
    @.logging_Service = null

  setup: ()=>
    if @.options.logging_Enabled
      @.set_Logging()
    @.set_BodyParser()
    @.remove_Unwanted_Headers()
    @.set_Config()
    @.set_Static_Route()
    @.add_Session()      # for now not using the async version of add_Session
    @.set_Views_Path()
    @set_Secure_Headers()
    @.map_Route('../routes/flare_routes')
    @.map_Route('../routes/routes')
    @

  set_Logging: ()=>
    @.logging_Service = new Logging_Service().setup()

    logger?.info('[TM-Server] Log is setup')
    global.info = console.log                   # legacy, global.info calls need to be changed to logger?.info
    info('Configuring TM_Design Express server')

  add_Session: (session_File)=>
    @.session_Service = new Session_Service({filename:session_File}).setup()
    @.app.use @.session_Service.session
    @

  set_BodyParser: ()=>
    @.app.use(bodyParser.json({limit:'1kb'})                       );     # to support JSON-encoded bodies
    @.app.use(bodyParser.urlencoded({limit:'1kb', extended: true }));     # to support URL-encoded bodies

  remove_Unwanted_Headers : () ->
    @.app.disable("x-powered-by")

  set_Config:()=>
    @.app.config = new Config(null, false);

  set_Static_Route:()=>
    @app.use(express['static'](path.join(__dirname,'../../')));

  set_Views_Path :()=>
    @.app.set('views', path.join(__dirname,'../../'))

  set_Secure_Headers: ()=>
    @.app.use(helmet.csp({
      defaultSrc: ["'self'"],
      scriptSrc: ["'none'"],
      styleSrc: ["'self'"]
      imgSrc: ["'self'"],
      objectSrc: ["'self'"],
      mediaSrc: ["'none'"],
      frameSrc: ["'self'"]
      #reportUri: '/csp', # Browser will POST reports of policy failures to this URI
      reportOnly: false, # set to true if you only want to report errors; site will still function
      setAllHeaders: false, # helmet sniffs user-agent of browser and sets appropriate header values;
                            # if no user-agent matched, it will set ALL headers w/ 1.0 spec
      disableAndroid: false # set to true to disable CSP on Android (can be flaky)
    }));
    @.app.use(helmet.hsts({    #http://tools.ietf.org/html/rfc6797 - HTTP Strict Transport Security
      maxAge: 10886400000,     # Milliseconds - must be at least 18 weeks to be approved by Google
      includeSubdomains: true, # Must be enabled to be approved by Google
      preload: true # Submits site for baked-into-Chrome HSTS by adding preload to header - https://hstspreload.appspot.com/
    }));
    @.app.use(helmet.hidePoweredBy()); # hides "X-Powered-By: Express" set by default in Express header

  map_Route: (file)=>
    require(file)(@)
    @

  start:()=>
    #if process.mainModule.filename.not_Contains(['node_modules','mocha','bin','_mocha'])
    console.log("Starting 'TM Jade' Poc on port " + @app.port)
    @app.server = @app.listen(@app.port)
    @

  checkAuth: (req, res, next, config)=>
    if (@.loginEnabled and req and req.session and !req.session.username)
      if req.url is '/'
        res.redirect '/index.html'
      else
        req.session.redirectUrl = req.url
        res.status(403)
           .send(new Jade_Service(config).renderJadeFile('/source/jade/guest/login-required.jade'))
    else
      next()

  mappedAuth: (req)->
    data = {};
    if(req && req.session)
      data =  {
        username  : req.session.username,
        loggedIn  : (req.session.username isnt undefined)
      }
    return data

module.exports = Express_Service