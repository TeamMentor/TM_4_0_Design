fs                 = null
request            = null
Jade_Service       = null
Docs_TM_Service    = null
content_cache = {};

class Help_Controller

  dependencies: ->
    fs                 = require('fs')
    request            = require('request')
    Jade_Service       = require('../services/Jade-Service')
    Docs_TM_Service    = require('../services/Docs-TM-Service');

  constructor: (req, res)->
    @.dependencies()
    @.pageParams       = {}
    @.req              = req
    @.res              = res
    @.docs_TM_Service  = new Docs_TM_Service()

    @.content          = null
    @.docs_Library     = null
    @.title            = null

    @.docs_Server      = 'https://docs.teammentor.net'
    @.gitHubImagePath  = 'https://raw.githubusercontent.com/TMContent/Lib_Docs/master/_Images/'
    @.jade_Help_Index  = '/source/jade/misc/help-index.jade'
    @.jade_Help_Page   = '/source/jade/misc/help-page.jade'
    @.index_Page_Id    = '1eda3d77-43e0-474b-be99-9ba118408dd3'
    @.jade_Error_Page  = '/source/jade/guest/404.jade'
    @.imagePath        = '../../.tmCache/Lib_Docs-json/_Images/'

  content_Cache_Set: (title, content)=>
    key = @.page_Id()
    if (key)
      content_cache[key] = { title: title,  content : content };

  content_Cache_Get: (title, content)=>
    content_cache[@.page_Id()]

  content_Cache: => content_cache

  fetch_Article_and_Show: (article_Title)=>
    if article_Title is null
      @show_Content("No content for the current page",'')
      return
    callback = @.docs_TM_Service.article_Data @.page_Id()
    if callback
        content =callback.html
        @show_Content(article_Title,content )
    else
        @show_Content('Error fetching page from docs site','')


  map_Docs_Library: (next)=>
    @.docs_TM_Service.getLibraryData (libraries)=>
      if(libraries? )
        @.docs_Library = libraries.first()
        next()
      else
        console.log("Documentation Library not found!")
        @.render_Jade_and_Send(@.jade_Error_Page,{})

  page_Id: =>
    @.req?.params?.page || null

  render_Jade_and_Send: (jade_Page, view_Model)=>
    view_Model.loggedIn = @.user_Logged_In()
    view_Model.library  = @.docs_Library
    html = new Jade_Service().render_Jade_File(jade_Page, view_Model)
    @.res.status(200)
         .send(html)

  redirect_Images_to_Folder: ()=>
    @.res.redirect @.imagePath + @.req.params.name

  show_Content: (title, content)=>
    if (content_cache[@.page_Id()]==undefined)
      @.content_Cache_Set title, content
    view_Model =
      title:   title
      content: content
    @.render_Jade_and_Send @.jade_Help_Page, view_Model

  show_Help_Page: ()=>
    @.map_Docs_Library =>
      cachedData = content_cache[@.page_Id()]
      if(cachedData)
        @.show_Content(cachedData.title, cachedData.content);
        return;

      @.fetch_Article_and_Show @.docs_Library?.Articles[@.page_Id()]?.Title || null

  show_Index_Page: ()=>
    #setting up index page
    @.req?.params?.page= @.index_Page_Id
    @map_Docs_Library =>
      @.fetch_Article_and_Show @.docs_Library?.Articles[@.page_Id()]?.Title || null

  user_Logged_In: ()=>
    @req.session?.username isnt undefined

Help_Controller.register_Routes =  (app)=>

  app.get '/help/index.html'      , (req, res)-> new Help_Controller(req, res).show_Index_Page()
  app.get '/help/article/:page*'  , (req, res)-> new Help_Controller(req, res).show_Help_Page()
  app.get '/help/:page*'          , (req, res)-> new Help_Controller(req, res).show_Help_Page()
  app.get '/Image/:name'          , (req, res)-> new Help_Controller(req, res).redirect_Images_to_Folder()

module.exports = Help_Controller
