fs           = require 'fs'
path         = require 'path'
{expect}     = require "chai"
Jade_Service = require '../../src/services/Jade-Service'


#used to understand better how jade compilation works (specialy how it compiles to java script)
describe "| services | Jade-Service |", ()->

    it 'check Jade-Service ctor', ()->
        using new Jade_Service(),->
            @.assert_Is_Object()

            @.config        .assert_Is_Object()
            @.target_Folder .assert_Is_String()
            @.repo_Path     .folder_Name().assert_Is('TM_4_0_Design')
            @.mixins_Folder .folder_Name().assert_Is('_mixins')
            @.mixin_Extends .assert_Is("..#{path.sep}_layouts#{path.sep}page_clean")

            @.compileJadeFileToDisk.assert_Is_Function()
            @.calculateTargetPath  .assert_Is_Function()
            @.enableCache          .assert_Is_Function()
            @.cacheEnabled         .assert_Is_Function()

            @.target_Folder         .assert_Is(@.config.jade_Compilation)

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
        targetFolder        = jadeService.target_Folder;

        targetFolder.assert_Is jadeService.config.jade_Compilation

        # if the compiled jade file is .js , we will have a circular auto compilation when running the tests using (for example) mocha -w node/tests/**/*jade*.js -R list
        using jadeService, ->
          @.calculateTargetPath("aaa"                            ).assert_Is targetFolder.append("#{path.sep}aaa.txt"             )
          @.calculateTargetPath("aaa#{path.sep}bbb"              ).assert_Is targetFolder.append("#{path.sep}aaa_bbb.txt"         )
          @.calculateTargetPath("aaa#{path.sep}bbb#{path.sep}ccc").assert_Is targetFolder.append("#{path.sep}aaa_bbb_ccc.txt"     )
          @.calculateTargetPath("aaa#{path.sep}bbb.jade"         ).assert_Is targetFolder.append("#{path.sep}aaa_bbb_jade.txt"    )
          @.calculateTargetPath("aaa#{path.sep}bbb.ccc.jade"     ).assert_Is targetFolder.append("#{path.sep}aaa_bbb_ccc_jade.txt")


    it 'calculateJadePath',->
        using new Jade_Service(), ->
          @.calculateJadePath("a.jade"                        ).assert_Is(@.repo_Path + "#{path.sep}a.jade")
          @.calculateJadePath("#{path.sep}a.jade"             ).assert_Is(@.repo_Path + "#{path.sep}a.jade")
          @.calculateJadePath("a#{path.sep}b.jade"            ).assert_Is(@.repo_Path + "#{path.sep}a#{path.sep}b.jade")
          @.calculateJadePath("#{path.sep}a#{path.sep}b.jade" ).assert_Is(@.repo_Path + "#{path.sep}a#{path.sep}b.jade")


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
        using new Jade_Service(),->

          @.renderJadeFile('a').assert_Is("");

          @.enableCache();

          helpJadeFile    = '/source/jade/misc/help-index.jade';

          @.renderJadeFile('a').assert_Is("");
          @.renderJadeFile(helpJadeFile, { structure: []}).assert_Is_Not('')
          @.renderJadeFile(helpJadeFile                  ).assert_Contains(    '<a id="nav-about" href="/guest/about.html">About</a>')
          @.renderJadeFile(helpJadeFile,{loggedIn:false} ).assert_Contains(    '<a id="nav-about" href="/guest/about.html">About</a>')
          @.renderJadeFile(helpJadeFile,{loggedIn:true}  ).assert_Not_Contains('<a id="nav-about" href="/guest/about.html">About</a>')

    it 'renderMixin', (done)->
      using new Jade_Service(),->
        @.renderMixin('search-mixins', 'results', {resultsTitle : 'AAAA'})
          .assert_Contains ['<!DOCTYPE html><html lang="en"', 'link href="/static/css/custom-style.css']
            #                 '<h5 id="resultsTitle">AAAA</h5>']
        done()

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
