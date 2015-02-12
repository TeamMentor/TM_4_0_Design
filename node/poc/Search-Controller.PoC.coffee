Config          = require('../misc/Config')
Express_Service = require('../services/Express-Service')
Jade_Service    = require('../services/Jade-Service')
Graph_Service   = require('../services/Graph-Service')
marked = require('marked');

class Search_Controller_PoC

  constructor: (req, res)->
    @req                = req
    @res                = res

    @jade_Service       = new Jade_Service()
    @graphService       = new Graph_Service()

  render_Page: (jade_Page,data)=>
    html = @jade_Service.renderJadeFile(jade_Page, data)
    @res.send html

  poc_Pages: =>
    target    = @.req.query.text
    jade_Page = '/source/jade/-poc-/poc-pages.jade'
    data =
      pages: [{ name: 'PoC pages'           , link: ''}]
    @render_Page jade_Page, data


  #md_Render: ()=>
  #  jade_Page = '/source/jade/-poc-/md-render.jade'
  #  md_text = @.req.body.md_text || ""
  #  options = {
  #                renderer: new marked.Renderer(),
  #                gfm: true,
  #                tables: true,
  #                breaks: true,
  #                pedantic: false,
  #                sanitize: true,
  #                smartLists: true,
  #                smartypants: false
  #              }
  #  marked.setOptions options
  #  #render_text = marked md_text
  #  tokens = marked.lexer(md_text,options)
  #  log tokens
  #  render_text = marked.parser(tokens)
  #  log tokens
  #  params = { md_text: md_text, md_html: render_text, tokens: tokens}
  #  raw_html = @jade_Service.renderJadeFile jade_Page, params
  #  html = raw_html.replace '{html_code}', render_text
  #  #tokens = marked.lexer(md_text, options)


  #  @res.send html
    #@render_Page



Search_Controller_PoC.registerRoutes = (app, expressService) ->

    expressService ?= new Express_Service()
    checkAuth       =  (req,res,next) -> expressService.checkAuth(req, res,next, app.config)

    searchController_PoC = (method_Name) ->
        return (req, res) ->
            new Search_Controller_PoC(req, res, app.config)[method_Name]()


    app.get  "/poc"                         , checkAuth,  searchController_PoC('poc_Pages')
#    app.get  "/-poc-/md-render"               , checkAuth,  searchController_PoC('md_Render')
#    app.post "/-poc-/md-render"               , checkAuth,  searchController_PoC('md_Render')

module.exports = Search_Controller_PoC