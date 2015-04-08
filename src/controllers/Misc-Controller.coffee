Jade_Service       = null

content_cache = {};

class Misc_Controller

  dependencies: ->
    Jade_Service       = require('../services/Jade-Service')

  constructor: (req, res)->
    @.dependencies()
    @.req = req || {}
    @.res = res || {}

  show_Misc_Page: ()=>
    jade_Page  = '/source/jade/misc/' + @.req.params.page + '.jade'
    view_Model = loggedIn: @.user_Logged_In()
    html = new Jade_Service().renderJadeFile(jade_Page, view_Model)
    @.res.status(200)
         .send(html)

  user_Logged_In: ()=>
    @req.session?.username isnt undefined

Misc_Controller.register_Routes =  (app)=>

  app.get '/misc/:page'     , (req, res)-> new Misc_Controller(req, res).show_Misc_Page()

module.exports = Misc_Controller