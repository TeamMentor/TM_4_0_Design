fs           = require('fs')
expect       = require("chai").expect
Jade_Service = require('../../services/Jade-Service')


#used to understand better how jade compilation works (specialy how it compiles to java script)
describe "services | Jade-Service.js", ()->

    it 'check Jade-Service ctor', ()->
        using new Jade_Service(),->
            @.assert_Is_Object()

            @.config       .assert_Is_Object()
            @.targetFolder .assert_Is_String()
        
            @.compileJadeFileToDisk.assert_Is_Function()
            @.calculateTargetPath  .assert_Is_Function()
            @.enableCache          .assert_Is_Function()
            @.cacheEnabled         .assert_Is_Function()

            @.targetFolder         .assert_Is(@.config.jade_Compilation)
    
    it 'enableCache , cacheEnabled', ()->
        using new Jade_Service(),->
          @.cacheEnabled()    .assert_Is_False()
          @.enableCache()     .assert_Is(@)
           .cacheEnabled()    .assert_Is_True()
          @.enableCache(false)
           .cacheEnabled()    .assert_Is_False()
          @.enableCache(true )
           .cacheEnabled()    .assert_Is_True()
    
    it 'calculateTargetPath', ()->
        jadeService = new Jade_Service();
        targetFolder        = jadeService.targetFolder;

        targetFolder.assert_Is jadeService.config.jade_Compilation

        # if the compiled jade file is .js , we will have a circular auto compilation when running the tests using (for example) mocha -w node/tests/**/*jade*.js -R list
        using jadeService, ->
          @.calculateTargetPath('aaa'             ).assert_Is targetFolder.append('/aaa.txt'             )
          @.calculateTargetPath('aaa/bbb'         ).assert_Is targetFolder.append('/aaa_bbb.txt'         )
          @.calculateTargetPath('aaa/bbb/ccc'     ).assert_Is targetFolder.append('/aaa_bbb_ccc.txt'     )
          @.calculateTargetPath('aaa/bbb.jade'    ).assert_Is targetFolder.append('/aaa_bbb_jade.txt'    )
          @.calculateTargetPath('aaa/bbb.ccc.jade').assert_Is targetFolder.append('/aaa_bbb_ccc_jade.txt')

    it 'repoPath', ()->
        using new Jade_Service(), ->
            @.repoPath().assert_Folder_Exists()
            @.repoPath().file_Name().assert_Is('TM_4_0_Design')

    it 'calculateJadePath',->
        using new Jade_Service(), ->
          @.calculateJadePath('.'        ).assert_Is(@.repoPath())
          @.calculateJadePath('a.jade'   ).assert_Is(@.repoPath() + '/a.jade')
          @.calculateJadePath('/a.jade'  ).assert_Is(@.repoPath() + '/a.jade')
          @.calculateJadePath('a/b.jade' ).assert_Is(@.repoPath() + '/a/b.jade')
          @.calculateJadePath('/a/b.jade').assert_Is(@.repoPath() + '/a/b.jade')


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
