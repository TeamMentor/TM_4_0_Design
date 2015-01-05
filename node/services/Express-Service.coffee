Config       = require('../misc/Config')
Jade_Service = require('../services/Jade-Service')
session      = require('express-session')
express      = require('express')

class Express_Service
  constructor: ()->
    @.app         = express()
    @loginEnabled = true;

  setup: ()=>
    @add_Session()
    @set_Config()
    @set_Static_Route()

  add_Session: ()=>
    @.app.use(session({secret: '1234567890', saveUninitialized: true , resave: true }));

  set_Config:()=>
    @.app.config = new Config(null, false);

  set_Static_Route:()=>
    @app.use(express['static'](process.cwd()));

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