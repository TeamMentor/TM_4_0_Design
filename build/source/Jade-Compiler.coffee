require 'fluentnode'
jade  = require('jade');
async = require('async')

#extra prototypes (to add to fluentnode)
String::files_Recursive = (extension)->
  files = []
  for item in @.str().files_and_Folders()
    if (item.is_Folder())
      files = files.concat(item.files_Recursive(extension))
    else
      if (not extension or item.file_Extension() is extension)
        files.push(item)
  return files

class Jade_Compiler
  default_Options =
    ignore_Underscore_Folders : true      # looks on the parent folder name of the jade file being compiled
    ignore_Mixins_Folders     : true      # looks to see if there is the word mixins on the path

  constructor: (options)->
    @options = options || default_Options

  compile: (code, callback)=>
    if not code
      callback '[Jade_Compiler][compile] provided value was null)', null, null
    else
      options = {}
      fn = jade.compileClient(code, options);
      callback(null, fn)

  compile_File: (file, callback)=>
    if not file or not file.file_Exists()
      callback '[Jade_Compiler][compile_File] provided file was null or didn\'t exit)', null, null
    else
      options = { filename:file, compileDebug : false}
      fn = jade.compileClient(file.file_Contents(), options);
      callback(null, fn)

  compile_File_To: (file,target, callback)=>
    if not file or not file.file_Exists() or not target
      callback '[Jade_Compiler][compile_File_To] provided file was null or not available', null, null
    else
      target_File = if target and target.is_Folder() then target.path_Combine(file.file_Name_Without_Extension()).append('.js') else target
      @compile_File file, (error,compiled_Jade,stats) ->
        if error
          callback(error, null, stats)
        else
          exportCode =  'var jade = require(\'jade/lib/runtime.js\'); \n' + 'module.exports = ' + compiled_Jade;
          target_File.file_Parent_Folder().file_Parent_Folder().folder_Create()
          target_File.file_Parent_Folder().folder_Create()
          exportCode.saveAs(target_File)
          callback null, target_File, stats

  compile_Files_To: (files, target,callback)=>
    async.each files, ((file,next)=> @compile_File_To(file,target,()->next())), callback

  compile_Folder_To: (source_Folder, target_Folder, callback)=>
    source_Files = source_Folder.files_Recursive(".jade")
    if (@options.ignore_Underscore_Folders)
      source_Files = (file for file in source_Files when file.file_Parent_Folder().file_Name().starts_With('_') is false and file.contains('mixins') is false)
    target_Folder.folder_Create()

    async.each source_Files, ((file, next)=> @compile_File_To(file, file.replace(source_Folder, target_Folder)+ '.js', ()->next())), callback

module.exports = Jade_Compiler