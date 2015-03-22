Config       = null
Jade_Service = null

class Jade_Controller
  constructor: (req, res, config)->

    Config        = require('../misc/Config')
    Jade_Service  = require('../services/Jade-Service')

    @.req          = req;
    @.res          = res;
    @.config       = config || new Config();
    @.jade_Service = new Jade_Service(@.config);


  renderMixin: (viewModel)=>
    if viewModel and viewModel.viewModel
      viewModel = JSON.parse viewModel.viewModel
    file  = @req.params.file
    mixin = @req.params.mixin
    html  = @.jade_Service.renderMixin(file, mixin,viewModel || {})
    @.res.send(html)

  renderMixin_GET: ()=>
    @renderMixin @.req.query

  renderMixin_POST: ()=>
    @renderMixin @.req.body

  renderFile: (viewModel)=>
    file_Raw  =  @.req.params.file.to_Safe_String().replace(/_/g,'/')
    file      = "/source/#{file_Raw}.jade"
    html      =  @.jade_Service.renderJadeFile(file, viewModel || {})
    @.res.send(html)

  renderFile_GET: ()=>
    @.renderFile @.req.query

Jade_Controller.register_Routes =  (app)=>

  app.get  '/render/mixin/:file/:mixin' ,    (req, res)=> new Jade_Controller(req, res, app.config).renderMixin_GET()
  app.post '/render/mixin/:file/:mixin' ,    (req, res)=> new Jade_Controller(req, res, app.config).renderMixin_POST()
  app.get  '/render/file/:file'         ,    (req, res)=> new Jade_Controller(req, res, app.config).renderFile_GET()


module.exports = Jade_Controller