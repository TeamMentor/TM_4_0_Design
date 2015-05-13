Jade_Service = null

register_Routes =   (express_Service)->

  Jade_Service = require('../services/Jade-Service')
  app          = express_Service.app

  preCompiler =
      renderJadeFile: (path)->
        #console.log('[renderJadeFile]' + path)
        return new Jade_Service(app.config).renderJadeFile(path)

      cleanCacheFolder: ()->


  preCompiler.cleanCacheFolder()

  app.get '/flare/_dev/:area/:page'  , (req, res)->  res.send preCompiler.renderJadeFile '/source/flare-dev/' + req.params.area + '/' + req.params.page + '.jade'
  app.get '/flare/_dev/all'          , (req, res)->  res.send preCompiler.renderJadeFile '/source/flare-dev/index.jade'
  app.get '/flare/_dev'              , (req, res)->  res.redirect '/flare/_dev/all'

  app.get '/flare/:page'             , (req, res)->  res.send preCompiler.renderJadeFile '/source/flare/' + req.params.page + '.jade'
  app.get '/flare'                   , (req, res)->  res.redirect '/flare/main-app-view'

  #app.get '/flare/main-app-view', (req, res)->  res.redirect '/flare/index'

module.exports = register_Routes