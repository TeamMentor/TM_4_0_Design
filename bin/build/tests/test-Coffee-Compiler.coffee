Coffee_Compiler = require('../source/Coffee-Compiler')

describe 'test-Coffee_Compiler',->
  source_Coffee = 'a=12;console.log a'
  expected_js   = "(function() {\n  var a;\n\n  a = 12;\n\n  console.log(a);\n\n}).call(this);\n"
  tmp_Coffee_File     = ".".fullPath().path_Combine('_tmp_Coffee.coffee')
  tmp_Coffee_Js_File  = ".".fullPath().path_Combine('_tmp_Coffee.js')

  coffee_Compiler = new Coffee_Compiler();

  before ->
    source_Coffee.saveAs(tmp_Coffee_File).assert_Is_True()

  after ->
    tmp_Coffee_File   .file_Delete().assert_Is_True()
    tmp_Coffee_Js_File.file_Delete().assert_Is_True()


  it 'constructor',->
    Coffee_Compiler.assert_Is_Function().ctor().assert_Is_Object()
    coffee_Compiler.assert_Is_Object()

  it 'compile', (done)->
    coffee_Compiler.compile.assert_Is_Function()
    coffee_Compiler.compile source_Coffee, (error,result)->
      assert_Is_Null(error)
      result.assert_Is(expected_js)
      done()

  it 'compile_File', (done)->
    coffee_Compiler.compile_File.assert_Is_Function()
    coffee_Compiler.compile_File tmp_Coffee_File, (error,result)->
      assert_Is_Null(error)
      result.assert_Is(expected_js)
      done()

  it 'compile_File (with bad data)', (done)->

    error_Message = "[Coffee_Compiler][compile_File] provided file was null or didn't exit)"

    compile_Bad_Data = (data, next)->
      coffee_Compiler.compile_File data, (error,result)->
        error.assert_Is(error_Message)
        assert_Is_Null(result)
        next()

    compile_Bad_Data null, ->
      compile_Bad_Data undefined, ->
        compile_Bad_Data '!@£$%^', ->
          done()

  it 'compile_File_To', (done)->
    coffee_Compiler.compile_File_To.assert_Is_Function()
    tmp_Coffee_Js_File.file_Delete().assert_Is_True()
    coffee_Compiler.compile_File_To tmp_Coffee_File, tmp_Coffee_Js_File, (error,result)->
      assert_Is_Null(error)
      result.assert_Is(tmp_Coffee_Js_File)
      tmp_Coffee_Js_File.assert_That_File_Exists()
      tmp_Coffee_Js_File.file_Contents().assert_Is(expected_js)
      done()

  it 'compile_Files_To', (done)->
    coffee_Compiler.compile_Files_To.assert_Is_Function()
    coffee_Compiler.compile_Files_To [tmp_Coffee_File], tmp_Coffee_Js_File, (error,result)->
      tmp_Coffee_Js_File.assert_That_File_Exists()
      done();

  it 'compile_Folder_To', (done)->
    sourceFolder   = '_tmp_folder'.append_To_Process_Cwd_Path().folder_Create().assert_That_Folder_Exists();
    sourceFolder_A = sourceFolder.path_Combine('A')     .folder_Create().assert_That_Folder_Exists();
    sourceFolder_B = sourceFolder.path_Combine('B')     .folder_Create().assert_That_Folder_Exists();
    source_Coffee.saveAs(sourceFolder_A.path_Combine('A.coffee'))
    source_Coffee.saveAs(sourceFolder_B.path_Combine('B.coffee'))
    source_Coffee.saveAs(sourceFolder_A.path_Combine('C.txt'))
    targetFolder   = '_tmp_folder_target'.append_To_Process_Cwd_Path()#.folder_Create().assert_That_Folder_Exists();
    coffee_Compiler.compile_Folder_To sourceFolder, targetFolder, ->
      targetFolder.files_Recursive().assert_Size_Is(2)
      targetFolder.path_Combine('/A/A.js').assert_That_File_Exists()
      targetFolder.path_Combine('/A/B.js').assert_That_File_Not_Exists()
      targetFolder.path_Combine('/B/B.js').assert_That_File_Exists()
      sourceFolder.folder_Delete_Recursive().assert_Is_True();
      targetFolder.folder_Delete_Recursive().assert_Is_True();
      done()