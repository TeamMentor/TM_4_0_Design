require 'fluentnode'
#fs           = require 'fs'
#path         = require 'path'
#{expect}     = require "chai"
Jade_Service = require '../../src/services/Jade-Service'


#used to understand better how jade compilation works (specialy how it compiles to java script)
describe.only "| services | Jade-Service |", ()->
  it 'constructor', ()->
    using new Jade_Service(),->
      @.assert_Is_Object()

      #@.target_Folder .assert_Is_String()
      #@.repo_Path     .folder_Name().replace(/-/g,'_').lower().assert_Is('tm_4_0_design') # in appveyor this is tm-4-0-design
      #@.mixins_Folder .folder_Name().assert_Is('_mixins')
      #@.mixin_Extends .assert_Is("..#{path.sep}_layouts#{path.sep}page_clean")

      @.apply_Highlight         .assert_Is_Function()
      @.calculate_Target_Path   .assert_Is_Function()
      @.cache_Enabled           .assert_Is_Function()
      @.compile_JadeFile_To_Disk.assert_Is_Function()
      @.render_Jade_File        .assert_Is_Function()
      @.render_Mixin            .assert_Is_Function()

          #@.target_Folder         .assert_Is(@.config.jade_Compilation)

  it 'apply_Highlight', ->
    no_Pre             = '<b>aaaa</b>'
    with_Pre           = no_Pre.append '<pre>var a=12;<br>b = function {}</pre>'
    with_Pre_Highlight = '<b>aaaa</b><pre><span class=\"keyword\">var</span> a=<span class=\"number\">12</span>;\nb = <span class=\"keyword\">function</span> {}</pre>'
    using new Jade_Service(),->
      @.apply_Highlight(no_Pre  ).assert_Is no_Pre
      @.apply_Highlight(with_Pre).assert_Is with_Pre_Highlight

  it 'cache_Enabled', ()->
    using new Jade_Service(),->
      @.cache_Enabled()    .assert_Is_False()
      global.config = jade_Compilation : enabled :true
      @.cache_Enabled()    .assert_Is_True()
      global.config = null
      @.cache_Enabled()    .assert_Is_False()


  it 'calculate_Target_Path', ()->
    using new Jade_Service(), ->

      target_Path = '_tmp_Jade_Compilation' #.assert_Folder_Not_Exists()
      global.config = jade_Compilation : path : '_tmp_Jade_Compilation'

      @.calculate_Target_Path("aaa"                  ).assert_Is target_Path.path_Combine('aaa.txt'             )
      @.calculate_Target_Path("aaa/bbb"              ).assert_Is target_Path.path_Combine('aaa_bbb.txt'         )
      @.calculate_Target_Path("aaa/bbb/ccc"          ).assert_Is target_Path.path_Combine('aaa_bbb_ccc.txt'     )
      @.calculate_Target_Path("aaa/bbb.jade"         ).assert_Is target_Path.path_Combine('aaa_bbb_jade.txt'    )
      @.calculate_Target_Path("aaa/bbb.ccc.jade"     ).assert_Is target_Path.path_Combine('aaa_bbb_ccc_jade.txt')
      target_Path.folder_Delete()

      global.config = null
      assert_Is_Undefined @.calculate_Target_Path "aaa"

    return
      #targetFolder        = jadeService.target_Folder;

      #targetFolder.assert_Is jadeService.config.jade_Compilation

      # if the compiled jade file is .js , we will have a circular auto compilation when running the tests using (for example) mocha -w node/tests/**/*jade*.js -R list



  return

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
