Jade_Service        = require('../services/Jade-Service')

module.exports =  (app)->

  preCompiler =
      renderJadeFile: (path)->
        console.log('[renderJadeFile]' + path)
        return new Jade_Service(app.config).renderJadeFile(path)

      cleanCacheFolder: ()->


  preCompiler.cleanCacheFolder()

  app.get '/flare/:area/:page'  , (req, res)->  res.send preCompiler.renderJadeFile '/source/flare/__ALL/' + req.params.area + '/' + req.params.page + '.jade'
  app.get '/flare/default'      , (req, res)->  res.send preCompiler.renderJadeFile '/source/flare/__ALL/default.jade'
  app.get '/flare/all'          , (req, res)->  res.send preCompiler.renderJadeFile '/source/flare/__ALL/index.jade'
  app.get '/flare'              , (req, res)->  res.redirect '/flare/all'
  app.get '/flare/main-app-view', (req, res)->  res.redirect '/flare/index'

