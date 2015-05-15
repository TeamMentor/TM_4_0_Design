fs             = null
path           = null
request        = null
Cache_Service  = null

class Docs_TM_Service

  constructor: ->

    fs             = require('fs')
    path           = require('path')
    request        = require('request')
    Cache_Service  = require('teammentor').Cache_Service

    @.disableCache           = false
    @._name                  = 'docs'
    @._tmSite                = 'https://docs.teammentor.net'
    @._tmWebServices         = '/Aspx_Pages/TM_WebServices.asmx/'
    @.cache                  = new Cache_Service("docs_cache")
    @.libraryDirectory       = __dirname.path_Combine '../../.tmCache/Lib_Docs-json'


  getFolderStructure_Libraries: (callback)=>
    json          = (@.libraryDirectory + "/Library/TM Documentation.json").load_Json();
    json_Library    = json.guidanceExplorer.library.first()
    callback json_Library

  getArticlesMetadata: (callback)=>
    json_Folder = @.libraryDirectory.path_Combine("Library")
    json_Files = json_Folder.files_Recursive(".json")
    articlesMetadata = {};
    articlesMetadata._numberOfArticles = 0;
    json_Files.forEach (file)->
      jsonFile = file.load_Json().TeamMentor_Article
      if (jsonFile?)
        metadata =
          Id         : jsonFile?.Metadata?.first().Id.first(),
          Title      : jsonFile?.Metadata?.first().Title.first(),
          Technology : jsonFile?.Metadata?.first().Technology?.first(),
          Phase      : jsonFile?.Metadata?.first().Phase?.first(),
          Type       : jsonFile?.Metadata?.first().Type?.first(),
          Category   : jsonFile?.Metadata?.first().Category?.first()

        articlesMetadata[metadata.Id]= metadata;
        articlesMetadata._numberOfArticles++;
    callback articlesMetadata;

  fileExist :() ->
    return ((@.libraryDirectory + "/Library/TM Documentation.json").file_Exists())

  documentationIndex:() ->
    return (@.libraryDirectory + "/Library/TM Documentation.json")

  getLibraryData: (callback)->
    #checking if documentation library was backported.
    if (@fileExist())
      @getFolderStructure_Libraries (tmLibrary)=>
        @.getArticlesMetadata (articlesMetadata)=>
          libraryData = [];
          library =
                    Title   : tmLibrary["$"].caption
                    Folders : [],
                    Views   : [],
                    Articles: {}

          tmLibrary.guidanceItems = [];
          views =tmLibrary?.libraryStructure?.first().view

          views.forEach (tmView) ->
            view = {Title: tmView['$'].caption, Articles: [] };
            items = tmView.items.first().item
            #Finding ids in views
            items.forEach (guidanceItemId)->
              articleMetadata = articlesMetadata[guidanceItemId];
              if(articleMetadata?)
                view   .Articles.push(articleMetadata);
                library.Articles[articleMetadata.Id] = articleMetadata;
            #Adding view to library
            library.Views.push(view);
            libraryData.push(library);
          callback libraryData
    else
      callback undefined

  json_Files: (callback)=>
    json_Folder = @.libraryDirectory.append("/Articles_Html")
    callback  json_Folder.files_Recursive(".json")

  article_Data: (articleId)=>
    @json_Files (jsonFiles)=>
      article_File = jsonFile for  jsonFile in   jsonFiles when jsonFile.contains(articleId)
      if article_File and article_File.file_Exists()
        return article_File.load_Json()
      else
        return null


module.exports = Docs_TM_Service