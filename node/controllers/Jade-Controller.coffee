Config        = require('../misc/Config')
Jade_Service  = require('../services/Jade-Service')


class Jade_Controller
  constructor: (req, res, config)->
    @.req          = req;
    @.res          = res;
    @.config       = config || new Config();
    @.jade_Service = new Jade_Service(@.config);

  renderMixin: (viewModel)=>
    file  = @req.params.file
    mixin = @req.params.mixin
    html  = @.jade_Service.renderMixin(file, mixin,viewModel || {})
    @.res.send(html)

  renderMixin_GET: ()=>
    @renderMixin @.req.query

  renderMixin_POST: ()=>
    @renderMixin @.req.body

Jade_Controller.registerRoutes =  (app)=>

  app.get  '/render/mixin/:file/:mixin' ,    (req, res)=> new Jade_Controller(req, res, app.config).renderMixin_GET()
  app.post '/render/mixin/:file/:mixin' ,    (req, res)=> new Jade_Controller(req, res, app.config).renderMixin_POST()


module.exports = Jade_Controller;