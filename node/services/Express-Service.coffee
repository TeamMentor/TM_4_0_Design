Config          = null
Jade_Service    = null
Express_Session = null
bodyParser      = null
session         = null
path            = null
express         = null

class Express_Service

  constructor: ()->
    Config           = require '../misc/Config'
    Jade_Service     = require '../services/Jade-Service'
    Express_Session  = require '../misc/Express-Session'
    bodyParser       = require 'body-parser'
    session          = require 'express-session'
    path             = require "path"
    express          = require 'express'
    @.app            = express()
    @loginEnabled    = true;
    @.app.port       = process.env.PORT || 1337;
    @.expressSession = null

  setup: ()=>
    @set_BodyParser()
    @set_Config()
    @set_Static_Route()
    @add_Session()      # for now not using the async version of add_Session
    @set_Views_Path()
    @.map_Route('../routes/flare_routes')
    @.map_Route('../routes/routes')
    @

  add_Session: (sessionFile)=>

    @.expressSession = new Express_Session({ filename: sessionFile || './.tmCache/_sessionData' ,session:session})
    @.app.use session({ secret: '1234567890', key: 'tm-session'
                        ,saveUninitialized: true , resave: true
                        , cookie: { path: '/' , httpOnly: true , maxAge: 365 * 24 * 3600 * 1000 }
                        , store: @.expressSession })


  set_BodyParser: ()=>
    @.app.use(bodyParser.json({limit:'1kb'})                       );     # to support JSON-encoded bodies
    @.app.use(bodyParser.urlencoded({limit:'1kb', extended: true }));     # to support URL-encoded bodies


  set_Config:()=>
    @.app.config = new Config(null, false);

  set_Static_Route:()=>
    @app.use(express['static'](process.cwd()));

  set_Views_Path :()=>
    @.app.set('views', path.join(__dirname,'../../'))

  map_Route: (file)=>
    require(file)(@.app,@);
    @

  start:()=>
    if process.mainModule.filename.not_Contains(['node_modules','mocha','bin','_mocha'])
      console.log("[Running locally or in Azure] Starting 'TM Jade' Poc on port " + @app.port)
      @app.server = @app.listen(@app.port)

  checkAuth: (req, res, next, config)=>
    if (@.loginEnabled and req and req.session and !req.session.username)
      if req.url is '/'
        res.redirect '/index.html'
      else
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

  viewedArticles: (callback)=>
    if not @.expressSession
      callback {}
    else
      @.expressSession.db.find {}, (err,sessionData)=>
          recent_Articles = []
          if sessionData
              for session in sessionData
                  if session.data.recent_Articles
                      for recent_article in session.data.recent_Articles
                          recent_Articles.add(recent_article)
          callback recent_Articles

module.exports = Express_Service