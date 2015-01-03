fs           = require('fs')
expect       = require("chai").expect
Jade_Service = require('../../services/Jade-Service')


#used to understand better how jade compilation works (specialy how it compiles to java script)
describe "services | Jade-Service.js", ()->

    it 'check Jade-Service ctor', ()->
        jadeService = new Jade_Service();
        expect(jadeService).to.be.an('Object'); 
        
        expect(jadeService                      ).to.be.an('Object');
        expect(jadeService.config               ).to.be.an('Object');
        expect(jadeService.targetFolder         ).to.be.an('String');
        
        expect(jadeService.compileJadeFileToDisk).to.be.an('function');
        expect(jadeService.calculateTargetPath  ).to.be.an('function');
        expect(jadeService.enableCache          ).to.be.an('function');
        expect(jadeService.cacheEnabled         ).to.be.an('function');

        expect(jadeService.targetFolder         ).to.equal(jadeService.config.jade_Compilation)
    
    it 'enableCache , cacheEnabled', ()->
        jadeService = new Jade_Service();
        expect(jadeService.cacheEnabled()    ).to.be.false;
        expect(jadeService.enableCache()     ).to.equal(jadeService);
        expect(jadeService.cacheEnabled()    ).to.be.true;
        expect(jadeService.enableCache(false)).to.equal(jadeService);
        expect(jadeService.cacheEnabled()    ).to.be.false;
        expect(jadeService.enableCache(true )).to.equal(jadeService);
        expect(jadeService.cacheEnabled()    ).to.be.true;
    
    it 'calculateTargetPath', ()->
        jadeService = new Jade_Service();
        targetFolder        = jadeService.targetFolder;

        expect(targetFolder                   ).to.equal(jadeService.config.jade_Compilation);
        expect(jadeService.calculateTargetPath).to.be.an('Function');
        expect(jadeService.calculateTargetPath('aaa'             )).to.equal(targetFolder + 'aaa.txt'             );       # if the compiled jade file is
        expect(jadeService.calculateTargetPath('aaa/bbb'         )).to.equal(targetFolder + 'aaa_bbb.txt'         );       # and .js , we will have a circular auto compilation
        expect(jadeService.calculateTargetPath('aaa/bbb/ccc'     )).to.equal(targetFolder + 'aaa_bbb_ccc.txt'     );       # when running the tests using (for example)
        expect(jadeService.calculateTargetPath('aaa/bbb.jade'    )).to.equal(targetFolder + 'aaa_bbb_jade.txt'    );       #     mocha -w node/tests/**/*jade*.js -R list
        expect(jadeService.calculateTargetPath('aaa/bbb.ccc.jade')).to.equal(targetFolder + 'aaa_bbb_ccc_jade.txt');

    it 'compileJadeFileToDisk', ()->
        jadeService = new Jade_Service();
        defaultJadeFile = '/source/jade/guest/default.jade';
                
        jadeService.compileJadeFileToDisk('a').assert_Is_False()
        
        targetPath    = jadeService.calculateTargetPath(defaultJadeFile);
        #if(fs.existsSync(targetPath)==false)
        jadeService.compileJadeFileToDisk(defaultJadeFile).assert_Is_True()
        jadeTemplate  = require(targetPath);
        jadeTemplate.assert_Is_Function()
        jadeTemplate().assert_Is_String()
        
        html = jadeTemplate();
        html.assert_Contains '<!DOCTYPE html><html lang="en"><head>'
    
    it 'renderJadeFile', ()->
        jadeService = new Jade_Service();

        jadeService.renderJadeFile('a').assert_Is("");

        jadeService.enableCache();
        
        helpJadeFile    = '/source/jade/help/index.jade';
        
        jadeService.renderJadeFile('a').assert_Is("");
        jadeService.renderJadeFile(helpJadeFile, { structure: []}).assert_Is_Not('')
        jadeService.renderJadeFile(helpJadeFile                  ).assert_Contains('<a href="/guest/about.html">About</a>')
        jadeService.renderJadeFile(helpJadeFile,{loggedIn:false} ).assert_Contains('<a href="/guest/about.html">About</a>')
        jadeService.renderJadeFile(helpJadeFile,{loggedIn:true}  ).assert_Not_Contains('<a href="/guest/about.html">About</a>')



    ###
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
    });
    ###

    

    #targetFolder      = preCompiler.targetFolder()
