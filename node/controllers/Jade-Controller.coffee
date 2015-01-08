Config        = require('../misc/Config')
Jade_Service  = require('../services/Jade-Service')


class Jade_Controller
  constructor: (req, res, config)->
    @.req          = req;
    @.res          = res;
    @.config       = config || new Config();
    @.jade_Service = new Jade_Service(@.config);

  renderMixin: ()=>
    file      = @req.params.file
    mixin     = @req.params.mixin

    if @req.query
      if @req.query.viewModel
        viewModel = JSON.parse(@req.query.viewModel)
      else
        viewModel = @req.query
    else
      viewModel = {}

    html  = @.jade_Service.renderMixin(file, mixin,viewModel)
    @.res.send(html)

Jade_Controller.registerRoutes =  (app)=>

  app.get '/render/mixin/:file/:mixin' ,    (req, res)=> new Jade_Controller(req, res, app.config).renderMixin()


module.exports = Jade_Controller;