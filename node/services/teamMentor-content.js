/*jslint node: true, expr:true */

var fs      = require('fs')         ,
    path    = require('path')       ,    
    request = require('request')    ;
    


var teamMentorContent = 
    {
        disableCache           : false ,
        _name                  : 'docs',
        _tmSite                : 'https://docs.teammentor.net',
        _tmWebServices         : '/Aspx_Pages/TM_WebServices.asmx/',
        _baseLocalDataFolder   : '/source/content/',
        _libraryData_CacheFile : 'LibraryData.json'
    };

teamMentorContent.calculateLocalPath = function(filename)
    {
        if(!filename) { return null; }
    
        var folder  = path.join(process.cwd(), teamMentorContent._baseLocalDataFolder, teamMentorContent._name);            
    
        if(fs.existsSync(folder) === false)
        {
            fs.mkdirSync(folder);
        }
        
        var localPath = path.join(folder, filename);
        return localPath;    
    };

teamMentorContent.calculateTargetUrl = function(wsName)
    {
        return teamMentorContent._tmSite + teamMentorContent._tmWebServices + wsName;         
    };

teamMentorContent.getJsonAndSaveToDisk = function(wsName, callback)
    {                        
        var targetFile = teamMentorContent.calculateLocalPath(wsName + '.json');
        var targetUrl  = teamMentorContent.calculateTargetUrl(wsName);
        console.log(targetFile)
        if(teamMentorContent.disableCache === false && fs.existsSync(targetFile))
        {
            callback(targetFile);
            return;
        }

        var options = {
                          method: 'post',
                          body: {},
                          json: true,
                          url: targetUrl
                      };
        request(options, function(error, response, body)  
                    {
                        if (error && error.code==="ENOTFOUND") { callback(); return; }                             
                        fs.writeFileSync(targetFile, JSON.stringify(body,null, " "));                        
                        callback(targetFile);                            
                    });
    };

teamMentorContent.getArticlesMetadata = function()
    {
        var getGuiObjects_File  = teamMentorContent.calculateLocalPath('GetGUIObjects.json');
        if(fs.existsSync(getGuiObjects_File) === false) { return null; }
    
        var guiObjects = JSON.parse(fs.readFileSync(getGuiObjects_File));
    
        var articlesMetadata = {};
        var mappings      = guiObjects.d.GuidanceItemsMappings;
        var uniqueStrings = guiObjects.d.UniqueStrings;
        
        articlesMetadata._numberOfArticles = 0;
    
        mappings.forEach(function(mapping)
            {
                var keys = mapping.split(',');                
                var metadata = {    Id         : uniqueStrings[keys[0]],
                                    Title      : uniqueStrings[keys[2]],
                                    Technology : uniqueStrings[keys[3]],
                                    Phase      : uniqueStrings[keys[4]],
                                    Type       : uniqueStrings[keys[5]],
                                    Category   : uniqueStrings[keys[6]]};
                
                articlesMetadata[metadata.Id]= metadata;  
                articlesMetadata._numberOfArticles++;
            });        
        return articlesMetadata;
    };

teamMentorContent.getLibraryData = function()
    {    
        var guiObjects_File         = teamMentorContent.calculateLocalPath('GetGUIObjects.json');
        var getFolderStructure_file = teamMentorContent.calculateLocalPath('GetFolderStructure_Libraries.json');
        
        if(fs.existsSync(guiObjects_File        ) === false || 
           fs.existsSync(getFolderStructure_file) === false  ) { return null;  }
        
        var getFolderStructure = JSON.parse(fs.readFileSync(getFolderStructure_file));
        var articlesMetadata   = teamMentorContent.getArticlesMetadata();
    
        var libraryData = [];
        getFolderStructure.d.forEach(function(tmLibrary)
            {
                var library = {                                       
                                    Title   : tmLibrary.name,
                                    Folders : [],
                                    Views   : [],
                                    Articles: {}
                                };
                
                tmLibrary.guidanceItems = [];
                
                tmLibrary.views.forEach(function (tmView)
                    {
                        var view = { Title: tmView.caption, Articles: [] };
                    
                        tmView.guidanceItems.forEach(function(guidanceItemId)
                            {
                                var articleMetadata = articlesMetadata[guidanceItemId];
                                view   .Articles.push(articleMetadata);
                                library.Articles[articleMetadata.Id] = articleMetadata;
                            });
                        library.Views.push(view);                        
                    });
                libraryData.push(library);
            });
        return libraryData;
    };

teamMentorContent.getLibraryData_FromCache = function()
    {    
        var libraryData_File = teamMentorContent.calculateLocalPath(teamMentorContent._libraryData_CacheFile);
        if(teamMentorContent.disableCache === false && fs.existsSync(libraryData_File))
        {
            return JSON.parse(fs.readFileSync(libraryData_File));            
        }
        var libraryData = teamMentorContent.getLibraryData();
        
        fs.writeFileSync(libraryData_File, JSON.stringify(libraryData,null, " "));
        return libraryData;  
    };

module.exports = teamMentorContent;