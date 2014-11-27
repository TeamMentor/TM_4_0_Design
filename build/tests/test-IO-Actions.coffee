IO_Actions = require('../source/IO-Actions')

describe 'test-IO-Actions',->
  tmp_File_1      = '_tmp_File_1.txt'.append_To_Process_Cwd_Path()
  tmp_File_2      = '_tmp_File_2.txt'.append_To_Process_Cwd_Path()
  file_Contents_1 = (20).random_Letters()
  file_Contents_2 = (20).random_Letters()

  io_Actions = new IO_Actions();

  before ->
    file_Contents_1.saveAs(tmp_File_1)
    file_Contents_2.saveAs(tmp_File_2)

  after ->
    tmp_File_1.file_Delete().assert_Is_True()
    tmp_File_2.file_Delete().assert_Is_True()

  it 'constructor',->
    Files_Copy.assert_Is_Function().ctor().assert_Is_Object()
    files_Copy.assert_Is_Object()

  it.only 'copy_File', (done)->
    io_Actions.copy_File.assert_Is_Function()
    target_File_1 = tmp_File_1.append('.new').assert_File_Not_Exists()

    io_Actions.copy_File tmp_File_1, target_File_1, ->
      target_File_1.assert_File_Exists()
                   .file_Contents().assert_Is(file_Contents_1)
      target_File_1.file_Delete().assert_Is_True()
      done()