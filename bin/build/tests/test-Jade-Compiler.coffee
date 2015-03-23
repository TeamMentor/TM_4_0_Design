Jade_Compiler = require('../source/Jade-Compiler')

describe 'test-Jade_Compiler',->
  source_jade   = 'div abc'
  expected_js  = "function template(locals) {\nvar buf = [];\nvar jade_mixins = {};\nvar jade_interp;\n\nbuf.push(\"<div>abc</div>\");;return buf.join(\"\");\n}"
  tmp_Jade_File     = ".".fullPath().path_Combine('_tmp_jade.jade')
  tmp_Jade_Js_File  = ".".fullPath().path_Combine('_tmp_jade.js')

  before ->
    source_jade.saveAs(tmp_Jade_File).assert_Is_True()

  after ->
    tmp_Jade_File.file_Delete().assert_Is_True()
    tmp_Jade_Js_File.file_Delete().assert_Is_True()

  jade_Compiler = new Jade_Compiler();

  it 'constructor',->
    Jade_Compiler.assert_Is_Function().ctor().assert_Is_Object()
    jade_Compiler.assert_Is_Object()
    jade_Compiler.options.assert_Is_Object()
    jade_Compiler.options.ignore_Underscore_Folders.assert_Is_True()
    jade_Compiler.options.ignore_Folders_Containing.assert_Is(['mixin'])
    options =
      ignore_Underscore_Folders : false
      ignore_Folders_Containing : ['abcd']
    jade_Compiler_With_Options = new Jade_Compiler(options)
    jade_Compiler_With_Options.options.assert_Is(options)

  it 'compile', (done)->
    jade_Compiler.compile.assert_Is_Function()
    jade_Compiler.compile source_jade, (error,result)->
      assert_Is_Null(error)
      result.assert_Is(expected_js)
      done()

  it 'compile_File', (done)->
    jade_Compiler.compile_File.assert_Is_Function()
    jade_Compiler.compile_File tmp_Jade_File, (error,result)->
      assert_Is_Null(error)
      result.assert_Is(expected_js)
      done()

  it 'compile_File_To', (done)->
    jade_Compiler.compile_File_To.assert_Is_Function()
    tmp_Jade_Js_File.file_Delete().assert_Is_True()
    jade_Compiler.compile_File_To tmp_Jade_File, tmp_Jade_Js_File, (error,result)->
      assert_Is_Null(error)
      result.assert_Is(tmp_Jade_Js_File)
      tmp_Jade_Js_File.assert_That_File_Exists()
      tmp_Jade_Js_File.file_Contents().assert_Is('var jade = require(\'jade/lib/runtime.js\'); \n' + 'module.exports = ' + expected_js)
      done()

  it 'compile_Files_To', (done)->
    jade_Compiler.compile_Files_To.assert_Is_Function()
    jade_Compiler.compile_Files_To [tmp_Jade_File], tmp_Jade_Js_File, (error,result)->
      tmp_Jade_Js_File.assert_That_File_Exists()
      done();

  it 'compile_Folder_To', (done)->
    sourceFolder   = '_tmp_folder'.append_To_Process_Cwd_Path().folder_Create().assert_That_Folder_Exists();
    sourceFolder_A = sourceFolder.path_Combine('A')     .folder_Create().assert_That_Folder_Exists();
    sourceFolder_B = sourceFolder.path_Combine('B')     .folder_Create().assert_That_Folder_Exists();
    sourceFolder_C = sourceFolder.path_Combine('_C')    .folder_Create().assert_That_Folder_Exists();
    sourceFolder_M = sourceFolder.path_Combine('mixins') .folder_Create().assert_That_Folder_Exists();
    source_jade.saveAs(sourceFolder_A.path_Combine('A.jade'))
    source_jade.saveAs(sourceFolder_B.path_Combine('B.jade'))
    source_jade.saveAs(sourceFolder_A.path_Combine('C.txt'))
    source_jade.saveAs(sourceFolder_C.path_Combine('an_Layout.jade'))
    source_jade.saveAs(sourceFolder_M.path_Combine('an_mixin.jade'))
    targetFolder   = '_tmp_folder_target'.append_To_Process_Cwd_Path()#.folder_Create().assert_That_Folder_Exists();
    jade_Compiler.compile_Folder_To sourceFolder, targetFolder, ->
      targetFolder.files_Recursive().assert_Size_Is(2)
      targetFolder.path_Combine('/A/A.jade.js').assert_That_File_Exists()
      targetFolder.path_Combine('/A/B.jade.js').assert_That_File_Not_Exists()
      targetFolder.path_Combine('/B/B.jade.js').assert_That_File_Exists()
      sourceFolder.folder_Delete_Recursive().assert_Is_True();
      targetFolder.folder_Delete_Recursive().assert_Is_True();
      done()

