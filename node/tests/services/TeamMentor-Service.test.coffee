fs                = require('fs')
path              = require('path')
expect            = require("chai").expect
TeamMentor_Service = require('../../services/TeamMentor-Service')

describe "| services | TeamMentor-Service.test", ()->

    teamMentorContent = null

    before ->
      teamMentorContent = new TeamMentor_Service()
      @timeout(4000)

    it 'check teamMentorContent default fields', ()->
      using new TeamMentor_Service(),->
        expect(@                         ).to.be.an('object')

        expect(@._tmSite                 ).to.be.an('string')
        expect(@._tmWebServices          ).to.be.an('string')
        #expect(@._baseLocalDataFolder    ).to.be.an('string')
        #expect(@._libraryData_CacheFile  ).to.be.an('string')

        #expect(@.calculateLocalPath      ).to.be.an('function')
        expect(@.calculateTargetUrl      ).to.be.an('function')
        expect(@.getArticlesMetadata     ).to.be.an('function')
        expect(@.getLibraryData          ).to.be.an('function')
        #expect(@.getLibraryData_FromCache).to.be.an('function')
        #expect(@.getJsonAndSaveToDisk    ).to.be.an('function')

        @.disableCache = false
    
    
  #  it 'calculateLocalPath', ()->
  #    fileName   = "abc.json"
  #    localPath  = teamMentorContent.calculateLocalPath(fileName)
#
  #    baseFolder = process.cwd() + teamMentorContent._baseLocalDataFolder +  teamMentorContent._name
#
  #    expect(fs.existsSync(baseFolder)).to.be.true
  #    expect(localPath).to.be.equal(path.join(baseFolder, fileName))

    
    it 'calculateTargetUrl', ()->
      wsName    = "GetGUIObjects";
      targetUrl = teamMentorContent.calculateTargetUrl(wsName);
      expect(targetUrl).to.be.equal('https://docs.teammentor.net/Aspx_Pages/TM_WebServices.asmx/GetGUIObjects');


    it 'asmx_GetFolderStructure_Libraries', (done)->
      using teamMentorContent, ->
        @.asmx_GetFolderStructure_Libraries =>
          @.cache.path_Key('json_post_' + @.calculateTargetUrl('GetFolderStructure_Libraries')).assert_File_Exists()
          done()

    it 'asmx_GetGUIObjects', (done)->
      using teamMentorContent, ->
        @.asmx_GetGUIObjects =>
          @.cache.path_Key('json_post_' + @.calculateTargetUrl('GetGUIObjects'               )).assert_File_Exists()
          done();

    #it 'getJsonAndSaveToDisk', (done)->
    #  teamMentorContent.getJsonAndSaveToDisk 'GetGUIObjects', (body,request)->
    #    log body
    #    done()

    #it 'getJsonAndSaveToDisk (bad tmSite)', (done)->
    #  #this will trigger the ENOTFOUND
    #  tmSite = teamMentorContent._tmSite
    #  teamMentorContent._tmSite = 'http://aaaaaaabb.teammentor.net'
    #  teamMentorContent.getJsonAndSaveToDisk 'aa',->
    #    teamMentorContent._tmSite = tmSite
    #    done()

    #it 'update GetFolderStructure_Libraries', (done)->
    #  teamMentorContent.disableCache =true; # find a lighter request to test this
#
    #  teamMentorContent.getJsonAndSaveToDisk "GetFolderStructure_Libraries", (targetFile)->
    #    expect(fs.existsSync(targetFile)).to.be.true;
    #    teamMentorContent.disableCache =false;
    #    done();
#
    #it 'update GetGUIObjects', (done)->
    #  teamMentorContent.getJsonAndSaveToDisk "GetGUIObjects", (targetFile)->
    #    targetFile.assert_File_Exists()
    #    done()

    it 'getArticlesMetadata', ()->
      teamMentorContent.getArticlesMetadata (articlesMetadata)->
        expect(articlesMetadata                  ).to.be.an('Object')
        expect(articlesMetadata._numberOfArticles).to.be.an('Number')
        expect(articlesMetadata._numberOfArticles).to.be.above(100)

        metadata = articlesMetadata["23a3c023-fc74-46fe-9a6e-e7ec2d136335"]

        expect(metadata           ).to.be.an('Object')
        expect(metadata.Title     ).to.be.equal('Installing TEAM Mentor Eclipse Plugin for Fortify')
        expect(metadata.Technology).to.be.equal('Eclipse Plugin')
        expect(metadata.Phase     ).to.be.equal('NA')
        expect(metadata.Type      ).to.be.equal('Documentation')
        expect(metadata.Category  ).to.be.equal('Administration')

        #teamMentorContent._name='_tmp_Docs'
        #getGuiObjects_File  = teamMentorContent.calculateLocalPath('GetGUIObjects.json');
        #articlesMetadata = teamMentorContent.getArticlesMetadata();   #getLibraryData test will reload this
        #assert_Is_Null(articlesMetadata)
        #libraryData = teamMentorContent.getLibraryData()
        #assert_Is_Null(libraryData)
        #getGuiObjects_File.parent_Folder().delete_Folder().assert_True()
        #teamMentorContent._name='docs'
    
    it 'getLibraryData', ()->
        teamMentorContent.getLibraryData (libraryData)->
        
          #check libraryData object types
          expect(libraryData).to.be.an('Array');
          expect(libraryData).to.be.not.empty;

          library = libraryData[0];

          expect(library         ).to.be.an('Object');
          expect(library.Title   ).to.be.an('String');
          expect(library.Views   ).to.be.an('Array');
          expect(library.Folders ).to.be.an('Array');
          expect(library.Articles).to.be.an('Object');

          view = library.Views[0];

          expect(view         ).to.be.an('Object');
          expect(view.Title   ).to.be.an('String');
          expect(view.Articles).to.be.an('Array');
          expect(view.Articles).to.be.not.empty;

          article_Id = view.Articles[0].Id;
          expect(article_Id   ).to.be.an('String');

          article = library.Articles[article_Id];
          expect(article      ).to.be.an('Object');

          #check libraryData object data
          expect(library.Title     ).to.be.equal('TM Documentation' );
          expect(view   .Title     ).to.be.equal('About TEAM Mentor');
          expect(article           ).to.deep.equal(view.Articles[0]);
          expect(article.Title     ).to.be.equal('What is new in this release?');
          expect(article.Technology).to.be.equal('TEAM Mentor');
          expect(article.Phase     ).to.be.equal('NA');
          expect(article.Type      ).to.be.equal('Documentation');
          expect(article.Category  ).to.be.equal('Administration');

    
  #  it 'getLibraryData_FromCache', ()->
  #    targetFile = teamMentorContent.calculateLocalPath(teamMentorContent._libraryData_CacheFile)
  #    targetFile.file_Delete() if targetFile.file_Exists()
#
  #    expect(fs.existsSync(targetFile)).to.be.false;
#
  #    libraryData = teamMentorContent.getLibraryData_FromCache();
#
  #    expect(fs.existsSync(targetFile)).to.be.true;
  #    expect(libraryData   ).to.be.an('Array');
  #    expect(libraryData[0]).to.be.an('Object');
  #    expect(libraryData).to.deep.equal(teamMentorContent.getLibraryData_FromCache())