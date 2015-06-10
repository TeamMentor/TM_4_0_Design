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
      @.mixin_Extends = "..#{path.sep}_layouts#{path.sep}page_clean"

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

    calculate_Compile_Path: (fileToCompile)->
      if compile_Folder = global.config?.tm_design?.folder_Jade_Compilation
        if compile_Folder.folder_Not_Exists()
          compile_Folder.folder_Create()
        return compile_Folder.path_Combine(fileToCompile.replace(/\//g,'_')
                                                        .replace(/\\/g,'_')
                                                        .replace(/\./g,'_') + '.txt')
      return null

    calculate_Jade_Path: (jade_File)=>
      if jade_File.file_Exists()                                    then return jade_File
      if jade_Folder = global.config?.tm_design?.folder_Jade_Files  then return jade_Folder.path_Combine(jade_File)
      log jade_Folder
      return null


    compile_JadeFile_To_Disk: (target)->

      jade_File = @.calculate_Jade_Path(target)

      if (not jade_File) or jade_File.file_Not_Exists() then return false

      targetFile_Path = @.calculate_Compile_Path(target);
      targetFile_Path.file_Delete()

      js_Code = jade.compileClient(jade_File.file_Contents() , { filename:jade_File, compileDebug : false} );

      exportCode =  'var jade = require(\'jade/lib/runtime.js\'); \n' +
                    'module.exports = ' + js_Code;

      exportCode.save_As(targetFile_Path)
                .file_Exists()

    render_Jade_File: (jadeFile, params)=>
      if params and params.article_Html
        params.article_Html = @.apply_Highlight(params.article_Html)
      if (@.cache_Enabled() is false)
        jadeFile_Path = @.calculate_Jade_Path(jadeFile)

        if jadeFile_Path?.file_Exists()
          return jade.renderFile(jadeFile_Path,params)
        return ""

      targetFile_Path = @.calculate_Compile_Path(jadeFile);
      if (fs.existsSync(targetFile_Path) == false)
          if (@.compile_JadeFile_To_Disk(jadeFile) == false)
              return "";

      return require(targetFile_Path)(params);

    render_Mixin: (file, mixin, params)=>
      safeFile      = file.to_Safe_String()                                   # only allow letter, numbers, comma, dash and underscore
      safeMixin     = mixin.to_Safe_String()
      dummyJade     = @.calculate_Jade_Path('/_mixins/tmp.jade')              # file to be provided to jade.compile (used to resolve the mixin file path)
      code = "extends #{@.mixin_Extends}    \n" +                               # add html head and body (with TM css, but no nav bar)
             "include #{safeFile}.jade      \n" +                             # imports mixin file
             "block content                 \n" +                             # where rendered mixin will be placed
             "  +#{safeMixin}                 "                               # mixin to render
      return jade.compile(code, {filename: dummyJade })(params)


module.exports = JadeService
