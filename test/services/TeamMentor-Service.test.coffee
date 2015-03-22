fs                = require('fs')
path              = require('path')
expect            = require("chai").expect
Docs_TM_Service   = require('../../src/services/Docs-TM-Service')

describe "| services | Docs-TM-Service.test", ()->

    docs_TM_Service = null

    before ->
      docs_TM_Service = new Docs_TM_Service()
      @timeout(4000)

    it 'check docs_TM_Service default fields', ()->
      using new Docs_TM_Service(),->
        expect(@                         ).to.be.an('object')
        expect(@._tmSite                 ).to.be.an('string')
        expect(@._tmWebServices          ).to.be.an('string')
        expect(@.calculateTargetUrl      ).to.be.an('function')
        expect(@.getArticlesMetadata     ).to.be.an('function')
        expect(@.getLibraryData          ).to.be.an('function')

        @.disableCache = false

    it 'calculateTargetUrl', ()->
      wsName    = "GetGUIObjects";
      targetUrl = docs_TM_Service.calculateTargetUrl(wsName);
      expect(targetUrl).to.be.equal('https://docs.teammentor.net/Aspx_Pages/TM_WebServices.asmx/GetGUIObjects');


    it 'asmx_GetFolderStructure_Libraries', (done)->
      using docs_TM_Service, ->
        @.asmx_GetFolderStructure_Libraries =>
          @.cache.path_Key('json_post_' + @.calculateTargetUrl('GetFolderStructure_Libraries')).assert_File_Exists()
          done()

    it 'asmx_GetGUIObjects', (done)->
      using docs_TM_Service, ->
        @.asmx_GetGUIObjects =>
          @.cache.path_Key('json_post_' + @.calculateTargetUrl('GetGUIObjects'               )).assert_File_Exists()
          done();

    it 'getArticlesMetadata', ()->
      docs_TM_Service.getArticlesMetadata (articlesMetadata)->
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
    
    it 'getLibraryData', ()->
        docs_TM_Service.getLibraryData (libraryData)->
        
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