/*jslint node: true */
"use strict";

var fs                = require('fs'),        
    marked            = require('marked'),
    request           = require('request'),
    auth              = require('./auth'),    
    preCompiler       = require(process.cwd() + '/node/services/jade-pre-compiler.js'),
    teamMentorContent = require(process.cwd() + '/node/services/teamMentor-content.js');


module.exports = function (app) 
{
    //to do
    /*var preLoadLibraryData = function()
    {
        
    }*/
    var libraryData      = teamMentorContent.getLibraryData_FromCache();            
    var library          = libraryData[0];       
    
    var getContent = function(page, callback)
        {            
            if (page === "index.html") 
            {
                var page_index_File     = './source/content/docs/page-index.md'   ; 
                var page_index_Markdown = fs.readFileSync(page_index_File, 'utf8'); 
                var page_index_Html     = marked(page_index_Markdown)             ;                 
                callback(null, page_index_Html);
            }
            else
            {   
                var article = library.Articles[page];                
                if (article)
                {
                    var docs_Url   = 'https://docs.teammentor.net/content/' + page;
                    request.get(docs_Url, function(error, response, body)  
                        {
                            if (error && error.code==="ENOTFOUND") 
                            { 
                                callback("Error fetching page from docs site");
                            }
                            else
                            {
                                callback(article.Title, body);
                            }
                        });    
                }
                else
                {
                    callback("No content for the current page");
                    return;
                }
            }            
        };
    var getHelpPageParams = function(req, callback)
        {
            var page           = req.params.page;
            var pageParams     = auth.mappedAuth(req);
            pageParams.library = library;
            getContent(page, function(title, content)
                {
                    pageParams.title   = title;
                    pageParams.content = content;
                    callback(pageParams);
                });
        };
    var getRenderedPage = function(params)
        {
            return preCompiler.renderJadeFile('/source/html/help/index.jade', params); 
        };

    app.get('/help/:page*' , function (req, res)  
        {          
            getHelpPageParams(req, function(pageParams)
                {
                    var html = getRenderedPage(pageParams);
                    res.status(200)
                       .send(html); 
                });            
        });
};