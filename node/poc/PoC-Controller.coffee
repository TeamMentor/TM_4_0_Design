Jade_Service    = null

#without

Array::remove_If_Contains = (value)->
  @.filter (word) -> word.not_Contains(value)


class PoC_Controller

  dependencies: ->
    Jade_Service       = require('../services/Jade-Service')

  constructor: (options)->
    @.dependencies()
    @.options         = options || {}
    @.dir_Poc_Pages   = __dirname.path_Combine '../../source/jade/__poc'
    @.jade_Service    = new Jade_Service()
    @.express_Service = @.options.express_Service
    @

  register_Routes: () =>
    app = @.express_Service?.app
    if app
      app.get '/poc*'           , @.check_Auth
      app.get '/poc'            , @.show_Index
      app.get '/poc/:page'      , @.show_Page
    @

  check_Auth: (req,res,next)=>
    if req?.session?.username
      return next()
    res.redirect '/guest/404'

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
        @.view_Model_For_Page page, req.session, (view_Model)=>
          @.render_Jade res, mapping.path, view_Model
        return
    res.redirect '/guest/404'

  render_Jade: (res, jade_Page, view_Model)=>
    view_Model.loggedIn = true
    res.status(200)
       .send @.jade_Service.renderJadeFile(jade_Page, view_Model)

  #specific mappings

  view_Model_For_Page: (page,session, callback)=>
    view_Model = {}

    Express_Service = require('../services/Express-Service')

    switch page

      when 'top-articles'
        view_Model.title = 'Top Articles'
        @.express_Service.session_Service.top_Articles (data)->
          view_Model.top_Articles = data
          callback view_Model
      when 'top-searches'
        view_Model.title = 'Top Searches'
        @.express_Service.session_Service.top_Searches (data)->
          view_Model.top_Searches = data
          callback view_Model

      when 'session-data'
        view_Model.title = 'Session Data'
        @.express_Service.session_Service.session_Data (data)->
          view_Model.session_Data = data
          callback view_Model

      when 'user-data'
        view_Model.title = 'User Data'
        @.express_Service.session_Service.user_Data session, (data)->
          view_Model.user_Data = data
          callback view_Model

      when 'users-searches'
        view_Model.title = 'User\'s Searches'
        @.express_Service.session_Service.users_Searches (data)->
          view_Model.users_Searches = data
          callback view_Model

      else
        view_Model.title = 'No model'
        callback view_Model


module.exports = PoC_Controller