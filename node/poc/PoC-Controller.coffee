Jade_Service    = null

class PoC_Controller

  dependencies: ->
    Jade_Service       = require('../services/Jade-Service')

  constructor: (req, res)->
    @.dependencies()
    @.req = req || {}
    @.res = res || {}

  poc_Pages: =>
    view_Model =
      pages: [{ name: 'Articles' , link: '/articles'}]
    @render_Jade 'poc-pages', view_Model

  show_PoC_Page: ()=>
    jade_Page  = @.req.params.page
    view_Model = loggedIn: @.user_Logged_In()
    render_Jade jade_Page, view_Model

  render_Jade: (jade_Page, view_Model)=>
    jade_Page  = "/source/jade/-poc-/#{jade_Page}.jade"
    html = new Jade_Service().renderJadeFile(jade_Page, view_Model)
    @.res.status(200)
         .send(html)

  user_Logged_In: ()=>
    (@req.session?.username != undefined)


PoC_Controller.register_Routes = (app, expressService) ->

    expressService ?= new Express_Service()
    checkAuth       =  (req,res,next) -> expressService.checkAuth(req, res,next, app.config)

    poc_Controller = (method_Name) ->
        return (req, res) ->
            new PoC_Controller(req, res, app.config)[method_Name]()


    app.get  "/poc"       , checkAuth,  poc_Controller('poc_Pages')
    app.get  "/poc/:page" , checkAuth,  poc_Controller('show_PoC_Page')

module.exports = PoC_Controller