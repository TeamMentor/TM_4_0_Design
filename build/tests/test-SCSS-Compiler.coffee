SCSS_Compiler = require('../source/SCSS-Compiler')

describe 'test-SCSS_Compiler',->
  source_scss   = '$font-stack: Helvetica, sans-serif;html { font: 100% $font-stack;}'
  expected_css  = 'html{font:100% Helvetica,sans-serif}'

  scss_Compiler = new SCSS_Compiler();
  it 'constructor',->
    SCSS_Compiler.assert_Is_Function().ctor().assert_Is_Object()
    scss_Compiler.assert_Is_Object()

  it 'compile (with good data)', (done)->
    scss_Compiler.compile.assert_Is_Function()
    scss_Compiler.compile source_scss, (error,result,stats)->
      assert_Is_Null(error)
      result.assert_Is(expected_css)
      stats.entry.assert_Is('data')
      #(12).assert_Is_Number();
      #stats.str().assert_Is('1416978347049')
      console.log stats.start.assert_Is_Number()
      done()


  it 'compile (with null data)', (done)->
      scss_Compiler.compile null, (result)->
        (result == null).assert_Is_True()
        done()


