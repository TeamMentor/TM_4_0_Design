fs      = require('fs')
path    = require('path')
request = require('request')
    


class TeamMentor_Service

  constructor: ->
    @.disableCache           = false
    @._name                  = 'docs'
    @._tmSite                = 'https://docs.teammentor.net'
    @._tmWebServices         = '/Aspx_Pages/TM_WebServices.asmx/'
    @._baseLocalDataFolder   = '/source/content/'
    @._libraryData_CacheFile = 'LibraryData.json'

  calculateLocalPath: (filename)->
    return null if(!filename)

    folder  = path.join(process.cwd(), @._baseLocalDataFolder, @._name);
    folder.folder_Create()
    path.join(folder, filename);

  calculateTargetUrl: (wsName)->
    @._tmSite + @._tmWebServices + wsName

  getJsonAndSaveToDisk: (wsName, callback)->
    targetFile = @.calculateLocalPath(wsName + '.json');
    targetUrl  = @.calculateTargetUrl(wsName);
    #console.log(targetFile)
    if(@.disableCache == false && fs.existsSync(targetFile))
      callback(targetFile);
      return

    options =
              method: 'post',
              body: {},
              json: true,
              url: targetUrl

    request options, (error, response, body)->
      if (error && error.code=="ENOTFOUND")
        callback()
        return
      fs.writeFileSync(targetFile, JSON.stringify(body,null, " "));
      callback(targetFile);

  getArticlesMetadata: ()->
    getGuiObjects_File  = @.calculateLocalPath('GetGUIObjects.json');
    if(fs.existsSync(getGuiObjects_File) == false)
      return null;
    guiObjects = JSON.parse(fs.readFileSync(getGuiObjects_File));
    
    articlesMetadata = {};
    mappings      = guiObjects.d.GuidanceItemsMappings;
    uniqueStrings = guiObjects.d.UniqueStrings;
        
    articlesMetadata._numberOfArticles = 0;
    
    mappings.forEach (mapping)->
      keys = mapping.split(',');
      metadata =
                      Id         : uniqueStrings[keys[0]],
                      Title      : uniqueStrings[keys[2]],
                      Technology : uniqueStrings[keys[3]],
                      Phase      : uniqueStrings[keys[4]],
                      Type       : uniqueStrings[keys[5]],
                      Category   : uniqueStrings[keys[6]]

      articlesMetadata[metadata.Id]= metadata;
      articlesMetadata._numberOfArticles++;

    return articlesMetadata;

  getLibraryData: ()->
        guiObjects_File         = @.calculateLocalPath('GetGUIObjects.json');
        getFolderStructure_file = @.calculateLocalPath('GetFolderStructure_Libraries.json');
        
        if(fs.existsSync(guiObjects_File        ) == false ||
           fs.existsSync(getFolderStructure_file) == false  )
                return null
        
        getFolderStructure = JSON.parse(fs.readFileSync(getFolderStructure_file));
        articlesMetadata   = @.getArticlesMetadata();
    
        libraryData = [];
        getFolderStructure.d.forEach (tmLibrary)->
                library =
                            Title   : tmLibrary.name,
                            Folders : [],
                            Views   : [],
                            Articles: {}
                
                tmLibrary.guidanceItems = [];
                
                tmLibrary.views.forEach (tmView)->
                        view = { Title: tmView.caption, Articles: [] };
                    
                        tmView.guidanceItems.forEach (guidanceItemId)->
                                articleMetadata = articlesMetadata[guidanceItemId];
                                view   .Articles.push(articleMetadata);
                                library.Articles[articleMetadata.Id] = articleMetadata;
                        library.Views.push(view);
                libraryData.push(library);
        return libraryData

  getLibraryData_FromCache: ()->
    libraryData_File = @calculateLocalPath(@._libraryData_CacheFile);
    if(@.disableCache == false && fs.existsSync(libraryData_File))
        return JSON.parse(fs.readFileSync(libraryData_File));
    libraryData = @getLibraryData();

    fs.writeFileSync(libraryData_File, JSON.stringify(libraryData,null, " "));
    return libraryData;

module.exports = TeamMentor_Service;