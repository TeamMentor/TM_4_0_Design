/*jslint node: true , expr:true */
/*global describe, it */

var fs           = require('fs'),
    expect       = require("chai").expect,
    Jade_Service = require('../../services/Jade-Service');


//used to understand better how jade compilation works (specialy how it compiles to java script) 
describe("services > Jade-Service.js", function()
{            
    it('check Jade-Service ctor', function()
    {   
        var jadeService = new Jade_Service();
        expect(jadeService).to.be.an('Object'); 
        
        expect(jadeService                      ).to.be.an('Object');
        expect(jadeService.config               ).to.be.an('Object');
        expect(jadeService.targetFolder         ).to.be.an('String');
        
        expect(jadeService.compileJadeFileToDisk).to.be.an('function');
        expect(jadeService.calculateTargetPath  ).to.be.an('function');
        expect(jadeService.enableCache          ).to.be.an('function');
        expect(jadeService.cacheEnabled         ).to.be.an('function');
                
        //var myConfig = new Config();        
        expect(jadeService.targetFolder         ).to.equal(jadeService.config.jade_Compilation);        
    });    
    
    it('enableCache , cacheEnabled', function()
    {
        var jadeService = new Jade_Service();
        expect(jadeService.cacheEnabled()     ).to.be.false;
        expect(jadeService.enableCache ()     ).to.equal(jadeService);
        expect(jadeService.cacheEnabled()     ).to.be.true;
        expect(jadeService.enableCache (false)).to.equal(jadeService);
        expect(jadeService.cacheEnabled()     ).to.be.false;
        expect(jadeService.enableCache (true )).to.equal(jadeService);
        expect(jadeService.cacheEnabled()     ).to.be.true;        
    });
    
    it('calculateTargetPath', function()
    {
        var jadeService = new Jade_Service();        
        var targetFolder        = jadeService.targetFolder;

        expect(targetFolder                   ).to.equal(jadeService.config.jade_Compilation);
        expect(jadeService.calculateTargetPath).to.be.an('Function');
        expect(jadeService.calculateTargetPath('aaa'             )).to.equal(targetFolder + 'aaa.txt'             );       // if the compiled jade file is 
        expect(jadeService.calculateTargetPath('aaa/bbb'         )).to.equal(targetFolder + 'aaa_bbb.txt'         );       // and .js , we will have a circular auto compilation
        expect(jadeService.calculateTargetPath('aaa/bbb/ccc'     )).to.equal(targetFolder + 'aaa_bbb_ccc.txt'     );       // when running the tests using (for example)
        expect(jadeService.calculateTargetPath('aaa/bbb.jade'    )).to.equal(targetFolder + 'aaa_bbb_jade.txt'    );       //     mocha -w node/tests/**/*jade*.js -R list
        expect(jadeService.calculateTargetPath('aaa/bbb.ccc.jade')).to.equal(targetFolder + 'aaa_bbb_ccc_jade.txt');
  //      
    });
            
    it('compileJadeFileToDisk', function()
    {
        var jadeService = new Jade_Service();
        var defaultJadeFile = '/source/html/default.jade';
                
        expect(jadeService.compileJadeFileToDisk('a')).to.be.false;        
        
        var targetPath    = jadeService.calculateTargetPath(defaultJadeFile);
                
        if(fs.existsSync(targetPath)===false)        
        {            
            expect(jadeService.compileJadeFileToDisk(defaultJadeFile)).to.be.true;
        }
        var jadeTemplate  = require(targetPath);
        expect(jadeTemplate  ).to.be.an('function');
        expect(jadeTemplate()).to.be.an('string');
        
        var html = jadeTemplate();
        expect(html).to.contain('<!DOCTYPE html><html lang="en"><head> ');        
    });
    
    it('renderJadeFile', function()
    {    
        var jadeService = new Jade_Service();
        
        jadeService.enableCache();
        
        var helpJadeFile    = '/source/html/help/index.jade'; 
        
        expect(jadeService.renderJadeFile('a')).to.be.equal("");
        
        expect(jadeService.renderJadeFile(helpJadeFile, { structure: []})).to.not.be.equal("");
        expect(jadeService.renderJadeFile(helpJadeFile                 )).to.contain    ('<a href="/deploy/html/landing-pages/about.html">About</a>'); 
        expect(jadeService.renderJadeFile(helpJadeFile,{loggedIn:false})).to.contain    ('<a href="/deploy/html/landing-pages/about.html">About</a>'); 
        expect(jadeService.renderJadeFile(helpJadeFile,{loggedIn:true })).to.not.contain('<a href="/deploy/html/landing-pages/about.html">About</a>'); 
        expect(jadeService.renderJadeFile(helpJadeFile,{loggedIn:false})).to.not.contain('<img src="/deploy/assets/icons/help.png" alt="Help">'); 
        expect(jadeService.renderJadeFile(helpJadeFile,{loggedIn:true })).to.contain    ('<img src="/deploy/assets/icons/help.png" alt="Help">');         
    });
    
    /*
    it('cleanCacheFolder', function()
    {
        var cacheFolder        = preCompiler.targetFolder();
        var filesInCacheFolder = fs.readdirSync(cacheFolder);
        
        expect(filesInCacheFolder).to.be.an('Array');
        expect(filesInCacheFolder).to.not.be.empty;
        preCompiler.cleanCacheFolder();
        
        filesInCacheFolder = fs.readdirSync(cacheFolder);
        expect(filesInCacheFolder).to.be.an('Array');
        expect(filesInCacheFolder).to.be.empty;        
    });*/
    

    //var targetFolder      = preCompiler.targetFolder()    
});