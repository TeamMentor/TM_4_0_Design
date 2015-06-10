fs        = null
path      = null
jade      = null
cheerio   = null
Highlight = null

class JadeService

    dependencies: ()->
      fs          = require('fs')
      path        = require('path')
      jade        = require('jade')
      cheerio     = require('cheerio')
      {Highlight} = require('highlight')

    constructor: ()->
      @.dependencies()

    apply_Highlight: (html)=>
      if html.not_Contains('<pre>')
        return html
      $ = cheerio.load(html)
      $('pre').each (i,elem)->
        if $(elem).text().trim() is ''
          $(elem).remove()
        else
          $(elem).find($('br')).replaceWith('\n')
          $(elem).replaceWith($('<pre>' + Highlight($(elem).text()) + '</pre>'))
      $.html()

    cache_Enabled: ()->
      global.config?.jade_Compilation?.enabled || false

    calculate_Target_Path: (fileToCompile)->
      if target_Folder = global.config?.jade_Compilation?.path
        if target_Folder.folder_Not_Exists()
          "creating folder #{target_Folder}".log()
          target_Folder.folder_Create()
        target_Folder.path_Combine(fileToCompile.replace(/\//g,'_')
                                                .replace(/\\/g,'_')
                                                .replace(/\./g,'_') + '.txt')

    calculate_Jade_Path: (jade_File)->
      if jade_File.file_Exists()
        return jade_File
      @.repo_Path.path_Combine(jade_File)

    compile_JadeFile_To_Disk: (fileToCompile)->

      fileToCompile_Path = @.calculate_Jade_Path(fileToCompile)

      if (fs.existsSync(fileToCompile_Path)==false)
        return false

      targetFile_Path = @.calculate_Target_Path(fileToCompile);

      if (fs.existsSync(targetFile_Path))
          fs.unlinkSync(targetFile_Path)

      fileContents = fs.readFileSync(fileToCompile_Path,  "utf8");
      file_Compiled = jade.compileClient(fileContents , { filename:fileToCompile_Path, compileDebug : false} );

      exportCode =  'var jade = require(\'jade/lib/runtime.js\'); \n' +
                    'module.exports = ' + file_Compiled;


      fs.writeFileSync(targetFile_Path, exportCode);
      return fs.existsSync(targetFile_Path);


    folder_Jade_Files: ->
      @.repo_Path      = __dirname.path_Combine("..#{path.sep}..")          #calculate the repo path as 3 folders above the current path

    folder_Mixins: =>
      @.mixins_Folder = @.folder_Jade_Files().path_Combine("#{path.sep}source#{path.sep}jade#{path.sep}_mixins#{path.sep}")


    render_Jade_File: (jadeFile, params)=>
      if params and params.article_Html
        params.article_Html = @.apply_Highlight(params.article_Html)
      if (@.cache_Enabled() is false)
        jadeFile_Path = @.calculate_Jade_Path(jadeFile)
        if (fs.existsSync(jadeFile_Path))
          return jade.renderFile(jadeFile_Path,params)
        return ""

      targetFile_Path = this.calculate_Target_Path(jadeFile);
      if (fs.existsSync(targetFile_Path) == false)
          if (this.compile_JadeFile_To_Disk(jadeFile) == false)
              return "";

      return require(targetFile_Path)(params);

    render_Mixin: (file, mixin, params)=>
      mixin_Extends = "..#{path.sep}_layouts#{path.sep}page_clean"

      safeFile      = file.to_Safe_String()                                   # only allow letter, numbers, comma, dash and underscore
      safeMixin     = mixin.to_Safe_String()
      dummyJade     = @.folder_Mixins().path_Combine("#{path.sep}tmp.jade")   # file to be provided to jade.compile (used to resolve the mixin file path)
      code = "extends #{mixin_Extends}    \n" +                               # add html head and body (with TM css, but no nav bar)
             "include #{safeFile}.jade      \n" +                             # imports mixin file
             "block content                 \n" +                             # where rendered mixin will be placed
             "  +#{safeMixin}                 "                               # mixin to render
      return jade.compile(code, {filename: dummyJade })(params)


module.exports = JadeService
