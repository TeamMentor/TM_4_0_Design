
util = require('util');

module.exports =  (app)->

    app.get '/module'    , (req,res)-> res.send '<pre>' + util.inspect(module)              + '</pre>'
    app.get '/mainModule', (req,res)-> res.send '<pre>' + util.inspect(process.mainModule)  + '</pre>'
    
    app.get '/session'   , (req,res)-> res.send req.session
    
    app.get '/dirName'   , (req,res)-> res.send __dirname
    app.get '/pwd'       , (req,res)-> res.send process.cwd()
    app.get '/test'      , (req,res)-> res.send 'from routes.js..'
    app.get '/ping'      , (req,res)-> res.send 'pong..'

