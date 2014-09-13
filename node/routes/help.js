/*jslint node: true */
"use strict";

var auth = require('./auth'),    
    preCompiler       = require(process.cwd() + '/node/services/jade-pre-compiler.js'),
    teamMentorContent = require(process.cwd() + '/node/services/teamMentor-content.js');


module.exports = function (app) 
{
    var preLoadLibraryData = function()
    {
        
    }
    var getHelpPageParams = function(req)
        {
            var libraryData = teamMentorContent.getLibraryData_FromCache();
            var pageParams  = auth.mappedAuth(req);
            
            pageParams.library = libraryData[0];
     //       console.log(pageParams.library.Views);
            return pageParams;
        };
    var getRenderedPage = function(page, params)
        {
            return preCompiler.renderJadeFile('/source/html/help/'+ page + '.jade', params); 
        };

    app.get('/help/:page.html' , function (req, res)  
        {             
            var html = getRenderedPage(req.params.page, getHelpPageParams(req));
            res.status(200)
               .send(html); 
        });
};