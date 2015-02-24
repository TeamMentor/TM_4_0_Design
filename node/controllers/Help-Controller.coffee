fs                 = null
marked             = null
request            = null
Express_Service    = null
Jade_Service       = null
Docs_TM_Service = null

content_cache = {};

class Help_Controller

  dependencies: ->
    fs                 = require('fs')
    marked             = require('marked')
    request            = require('request')
    Express_Service    = require('../services/Express-Service')
    Jade_Service       = require('../services/Jade-Service')
    Docs_TM_Service    = require('../services/Docs-TM-Service');

  constructor: (req, res)->
    @dependencies()
    @.content_cache    = content_cache
    @.pageParams       = {}
    @.req              = req
    @.res              = res
    @.docs_TM_Service  = new Docs_TM_Service()

    @.page             = req?.params?.page || null
    @.title            = null
    @.content          = null

    @.docs_Server     = 'https://docs.teammentor.net'
    @.gitHubImagePath = 'https://raw.githubusercontent.com/TMContent/Lib_Docs/master/_Images/'
    @.index_Md_Page   = './../../source/content/help/page-index.md'
    @.jade_Page       = '/source/jade/misc/help.jade'

  addContent: (title, content)=>
    content_cache[this.page] = { title: title,  content : content };
    @.pageParams.title   = title;
    @.pageParams.content = content;
    @sendResponse(@.pageParams);

  clearContentCache: ()=>
    @.content_cache = {}
    content_cache   = {}

  getRenderedPage: (params)=>
    new Jade_Service().renderJadeFile(@.jade_Page, params)

  getContent: ()=>
    cachedData = content_cache[@.page];
    @.docs_TM_Service.getLibraryData (libraries)=>
      library = libraries.first()
      @.pageParams.library = library
      if(cachedData)
        @addContent(cachedData.title, cachedData.content);
        return;

      if (@.page == "index.html")
        page_index_File     = __dirname.path_Combine(@.index_Md_Page)
        page_index_Markdown = page_index_File.file_Contents()
        page_index_Html     = marked(page_index_Markdown)             ;
        @addContent(null, page_index_Html);
      else
        @.article = library.Articles[@.page];
        if (@.article)
          docs_Url   = @.docs_Server + '/content/' + @.page;
          request.get(docs_Url, @.handleFetchedHtml);
        else
          @addContent("No content for the current page");

  handleFetchedHtml: (error, response, body)=>
    if (error && error.code is "ENOTFOUND")
        @addContent("Error fetching page from docs site")
    else
        @addContent(@.article.Title, body)

  sendResponse: (pageParams)=>
    html = @getRenderedPage(pageParams);
    @.res.status(200)
         .send(html)

  redirectImagesToGitHub: ()=>
    @.res.redirect(@.gitHubImagePath + @.req.params.name);

  renderPage: ()=>
    @.pageParams         = new Express_Service().mappedAuth(@req)
    @.getContent(@.page)


module.exports = Help_Controller
