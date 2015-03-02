Jade_Service    = null

#without

Array::remove_If_Contains = (value)->
  @.filter (word) -> word.not_Contains(value)


class PoC_Controller

  dependencies: ->
    Jade_Service       = require('../services/Jade-Service')

  constructor: ()->
    @.dependencies()
    @.dir_Poc_Pages = __dirname.path_Combine '../../source/jade/__poc'
    @.jade_Service  = new Jade_Service()

  register_Routes: (app) ->
    app.get '/poc*'      , @.check_Auth
    app.get '/poc'       , @.show_Index
    app.get '/poc/:page' , @.show_Page
    @

  check_Auth: (req,res,next)=>
    if req?.session?.username
      return next()
    res.redirect '/guest/403'

  jade_Files: =>
    @.dir_Poc_Pages.files_Recursive().remove_If_Contains('mixin').remove_If_Contains('poc-pages')

  map_Files_As_Pages: =>
    extra_Mappings = [{ name: 'Articles' , link: '/articles'}]
    pages          = extra_Mappings
    for jade_File in @.jade_Files()
      fileName = jade_File.file_Name_Without_Extension()
      pages.push { name: fileName, link: "/poc/#{fileName}", path: jade_File}
    pages

  show_Index: (req,res)=>
    view_Model = {pages: @.map_Files_As_Pages() }
    jade_Page  = "#{@.dir_Poc_Pages}/poc-pages.jade"
    @render_Jade res, jade_Page, view_Model

  show_Page: (req,res)=>
    page  = req.params.page
    for mapping in @.map_Files_As_Pages()
      if mapping.link is "/poc/#{page}"
        return @.render_Jade res, mapping.path, {}
    res.redirect '/guest/404'

  render_Jade: (res, jade_Page, view_Model)=>
    view_Model.loggedIn = true
    res.status(200)
       .send @.jade_Service.renderJadeFile(jade_Page, view_Model)




module.exports = PoC_Controller