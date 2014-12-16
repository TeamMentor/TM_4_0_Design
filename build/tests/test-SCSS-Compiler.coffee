SCSS_Compiler = require('../source/SCSS-Compiler')

describe 'test-SCSS_Compiler',->
  source_scss   = '$font-stack: Helvetica, sans-serif;html { font: 100% $font-stack;}'
  expected_css  = 'html{font:100% Helvetica,sans-serif}'
  tmp_Scss_File = ".".fullPath().path_Combine('_tmp_scss.scss')
  tmp_Css_File  = ".".fullPath().path_Combine('_tmp_scss.css')

  before ->
    source_scss.saveAs(tmp_Scss_File).assert_Is_True()

  after ->
    tmp_Scss_File.file_Delete().assert_Is_True()
    tmp_Css_File.file_Delete().assert_Is_True()

  scss_Compiler = new SCSS_Compiler();
  it 'constructor',->
    SCSS_Compiler.assert_Is_Function().ctor().assert_Is_Object()
    scss_Compiler.assert_Is_Object()

  it 'compile', (done)->
    scss_Compiler.compile.assert_Is_Function()
    scss_Compiler.compile source_scss, (error,result,stats)->
      assert_Is_Null(error)
      result        .assert_Is(expected_css)
      stats.entry   .assert_Is('data')
      stats.start   .assert_Is_Number()
      stats.end     .assert_Is_Number()
      stats.duration.assert_Is_Number()
      assert_Is_Undefined(stats.sourceMap)
      done()

  it 'compile (with bad data)', (done)->
      scss_Compiler.compile 'asd123@£$@£$%', (error, result, stats)->
        error.assert_Instance_Of(String).assert_Is('stdin:1: invalid top-level expression\n')
        assert_Is_Null(result)
        stats.entry   .assert_Is('data')
        stats.start   .assert_Is_Number()
        assert_Is_Undefined(stats.end)
        assert_Is_Undefined(stats.duration)
        assert_Is_Undefined(stats.sourceMap)
        done()


  it 'compile (with null data)', (done)->
    scss_Compiler.compile null, (error, result,stats)->
      error.assert_Instance_Of(String).assert_Is('[SCSS_Compiler][compile] provided value was null)')
      assert_Is_Null(result)
      assert_Is_Null(stats)
      done()

  it 'compile_File ', (done)->
    scss_Compiler.compile_File tmp_Scss_File, (error,css,stats)->
      assert_Is_Null(error)
      css.assert_Is(expected_css)
      stats.includedFiles.assert_Is_Array()
                         .assert_Size_Is(1).first()
                                           .assert_Is(tmp_Scss_File)
      done();

  it 'compile_File_To', (done)->
    tmp_Css_File.file_Delete().assert_Is_True()
    scss_Compiler.compile_File_To tmp_Scss_File, tmp_Css_File, (error,cssFile,stats)->
      assert_Is_Null(error)
      cssFile.assert_Is(tmp_Css_File)
      cssFile.file_Contents().assert_Is(expected_css)
      stats.assert_Is_Object()
      done()

  it 'compile_File_To (scss folder)', (done)->
    tmp_Css_File.file_Delete().assert_Is_True()
    scss_Folder =  tmp_Css_File.file_Parent_Folder()
    scss_Compiler.compile_File_To tmp_Scss_File, scss_Folder, (error,cssFile,stats)->
      assert_Is_Null(error)
      cssFile.assert_Is(tmp_Css_File)
      cssFile.file_Contents().assert_Is(expected_css)
      stats.assert_Is_Object()
      done()

  it 'compile_File_To (no file provided)', (done)->
    scss_Compiler.compile_File_To 'a', null, (error,cssFile,stats)->
      error.assert_Is('[SCSS_Compiler][compile_File_To] provided file was null or not available')
      done()