require 'fluentnode'
coffee = require('coffee-script');
async  = require('async')

class Coffee_Compiler

  compile: (code, callback)=>
    if not code
      callback '[Coffee_Compiler][compile] provided value was null)', null, null
    else
      js = coffee.compile(code)
      callback(null, js)

  compile_File: (file, callback)=>
    if not file or not file.file_Exists()
      callback '[Coffee_Compiler][compile_File] provided file was null or didn\'t exit)', null, null
    else
      fn = coffee._compileFile(file);
      callback(null, fn)

  compile_File_To: (file, target, callback)=>
    if not file or not file.file_Exists() or not target
      callback '[Coffee_Compiler][compile_File_To] provided file was null or not available', null, null
    else
      target_File = if target and target.is_Folder() then target.path_Combine(file.file_Name_Without_Extension()).append('.js') else target
      @compile_File file, (error, compiled_Coffee, stats) ->
        if error
          callback(error, null, stats)
        else
          target_File.file_Parent_Folder().file_Parent_Folder().folder_Create()
          target_File.file_Parent_Folder().folder_Create()
          compiled_Coffee.saveAs(target_File)
          callback null, target_File, stats

  compile_Files_To: (files, target,callback)=>
    async.each files, ((file,next)=> @compile_File_To(file,target,()->next())), callback

  compile_Folder_To: (source_Folder, target_Folder, callback)=>
    source_Files = source_Folder.files_Recursive(".coffee")
    target_Folder.folder_Create()
    async.each source_Files, ((file, next)=> @compile_File_To(file, file.replace(source_Folder, target_Folder).replace('.coffee','.js'), ()->next())), callback

module.exports =  Coffee_Compiler
