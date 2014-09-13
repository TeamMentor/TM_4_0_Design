/*jslint node: true, expr:true */
/*global describe, it */

var fs                = require('fs')         ,
    path              = require('path')       ,    
    expect            = require("chai").expect,
    teamMentorContent = require('../../services/teamMentor-content.js');

describe("services > test-teamMentor-content.js", function()
{        
    it('check teamMentorContent default fields', function()
    {   
        expect(teamMentorContent                         ).to.be.an('object');
        
        expect(teamMentorContent._tmSite                 ).to.be.an('string');
        expect(teamMentorContent._tmWebServices          ).to.be.an('string');
        expect(teamMentorContent._baseLocalDataFolder    ).to.be.an('string');
        expect(teamMentorContent._libraryData_CacheFile  ).to.be.an('string');                
        
        expect(teamMentorContent.calculateLocalPath      ).to.be.an('function');
        expect(teamMentorContent.calculateTargetUrl      ).to.be.an('function');        
        expect(teamMentorContent.getArticlesMetadata     ).to.be.an('function'); 
        expect(teamMentorContent.getLibraryData          ).to.be.an('function');  
        expect(teamMentorContent.getLibraryData_FromCache).to.be.an('function');          
        expect(teamMentorContent.getJsonAndSaveToDisk    ).to.be.an('function'); 
        
        teamMentorContent.disableCache = false; 
    });
    
    
    it('calculateLocalPath', function()
    {
        var fileName   = "abc.json";        
        var localPath  = teamMentorContent.calculateLocalPath(fileName);
        
        var baseFolder = process.cwd() + teamMentorContent._baseLocalDataFolder +  teamMentorContent._name;    
        
        expect(fs.existsSync(baseFolder)).to.be.true;        
        expect(localPath).to.be.equal(path.join(baseFolder, fileName));
    });
    
    it('calculateTargetUrl', function()
    {
        var wsName    = "GetGUIObjects";
        var targetUrl = teamMentorContent.calculateTargetUrl(wsName);
        expect(targetUrl).to.be.equal('https://docs.teammentor.net/Aspx_Pages/TM_WebServices.asmx/GetGUIObjects');
    });
    
    it('update GetFolderStructure_Libraries', function(done)
    {   
                        
        teamMentorContent.getJsonAndSaveToDisk( "GetFolderStructure_Libraries",
            function(targetFile)  {
                                        expect(fs.existsSync(targetFile)).to.to.be.true;
                                        done();
                                  });
    });    

    it('update GetGUIObjects', function(done)
    {                   
        teamMentorContent.getJsonAndSaveToDisk("GetGUIObjects", 
            function(targetFile)   {
                                        expect(fs.existsSync(targetFile)).to.to.be.true;
                                        done();
                                   });
    });
    
    it('getArticlesMetadata', function()
    {
        var articlesMetadata = teamMentorContent.getArticlesMetadata();
        
        expect(articlesMetadata                  ).to.be.an   ('Object');
        expect(articlesMetadata._numberOfArticles).to.be.an   ('Number');
        expect(articlesMetadata._numberOfArticles).to.be.above(100);
        
        var metadata = articlesMetadata["23a3c023-fc74-46fe-9a6e-e7ec2d136335"];
        
        expect(metadata           ).to.be.an   ('Object');        
        expect(metadata.Title     ).to.be.equal('Installing TEAM Mentor Eclipse Plugin for Fortify');
        expect(metadata.Technology).to.be.equal('Eclipse Plugin');
        expect(metadata.Phase     ).to.be.equal('NA');
        expect(metadata.Type      ).to.be.equal('Documentation');
        expect(metadata.Category  ).to.be.equal('Administration');        
    });
    
    it('getLibraryData', function()
    {
        var libraryData = teamMentorContent.getLibraryData();    
        
        //check libraryData object types
        expect(libraryData).to.be.an('Array');   
        expect(libraryData).to.be.not.empty; 
        
        var library = libraryData[0];        
        
        expect(library        ).to.be.an('Object');
        expect(library.Title  ).to.be.an('String');
        expect(library.Views  ).to.be.an('Array');        
        expect(library.Folders).to.be.an('Array');
        
        var view = library.Views[0];
        
        expect(view         ).to.be.an('Object');
        expect(view.Title   ).to.be.an('String');
        expect(view.Articles).to.be.an('Array'); 
        expect(view.Articles).to.be.not.empty;
        
        var article = view.Articles[0];
        expect(article     ).to.be.an('Object');
        
        //check libraryData object data
        expect(library.Title     ).to.be.equal('TM Documentation' );       
        expect(view   .Title     ).to.be.equal('About TEAM Mentor');
        expect(article.Title     ).to.be.equal('What is new in this release?');
        expect(article.Technology).to.be.equal('TEAM Mentor');
        expect(article.Phase     ).to.be.equal('NA');
        expect(article.Type      ).to.be.equal('Documentation');
        expect(article.Category  ).to.be.equal('Administration');
    });
    
    it('getLibraryData_FromCache', function()
    {
        var targetFile = teamMentorContent.calculateLocalPath(teamMentorContent._libraryData_CacheFile);
        if(fs.existsSync(targetFile)) {  fs.unlinkSync(targetFile); }
        expect(fs.existsSync(targetFile)).to.be.false;
        
        var libraryData = teamMentorContent.getLibraryData_FromCache();
        
        expect(fs.existsSync(targetFile)).to.be.true;
        expect(libraryData   ).to.be.an('Array');
        expect(libraryData[0]).to.be.an('Object');        
        expect(libraryData).to.deep.equal(teamMentorContent.getLibraryData_FromCache());
    });
    
});