require 'fluentnode'
fs                 = require('fs')
marked             = require('marked')
request            = require('request')
Express_Service    = require('../services/Express-Service')
Jade_Service       = require('../services/Jade-Service')
TeamMentor_Service = require('../services/TeamMentor-Service');


content_cache = {};
#libraryData    = new TeamMentor_Service().getLibraryData_FromCache();
#library        = libraryData.first();

class Help_Controller
  constructor: (req, res)->
    @.page          = if (req and req.params) then req.params.page else null
    @.pageParams    = {}
    @.req           = req
    @.res           = res
    @.content_cache = content_cache
    @.title         = null
    @.content       = null
    @.teamMentor    = new TeamMentor_Service()
    @.docs_Server   = 'https://docs.teammentor.net'

  renderPage: ()=>
    @.pageParams         = new Express_Service().mappedAuth(@req)
    @.getContent(@.page)

  getContent: ()=>
    cachedData = content_cache[@.page];
    @.teamMentor.getLibraryData (libraries)=>
      library = libraries.first()
      @.pageParams.library = library
      if(cachedData)
        @addContent(cachedData.title, cachedData.content);
        return;

      if (@.page == "index.html")
        page_index_File     = __filename.parent_Folder().path_Combine('./../../source/content/help/page-index.md')
        page_index_Markdown = fs.readFileSync(page_index_File, 'utf8');
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
    if (error && error.code=="ENOTFOUND")
        @addContent("Error fetching page from docs site")
    else
        @addContent(@.article.Title, body)

  addContent: (title, content)=>
    content_cache[this.page] = { title: title,  content : content };
    @.pageParams.title   = title;
    @.pageParams.content = content;
    @sendResponse(@.pageParams);

  getRenderedPage: (params)=>
    new Jade_Service().renderJadeFile('/source/jade/help/index.jade', params)

  sendResponse: (pageParams)=>
    html = @getRenderedPage(pageParams);
    @.res.status(200)
         .send(html)

  clearContentCache: ()=>
    @.content_cache = {}
    content_cache   = {}

  redirectImagesToGitHub: ()=>
    gitHubImagePath = 'https://raw.githubusercontent.com/TMContent/Lib_Docs/master/_Images/';
    @.res.redirect(gitHubImagePath + @.req.params.name);


module.exports = Help_Controller;