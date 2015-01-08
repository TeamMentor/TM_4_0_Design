IO_Actions = require('../source/IO-Actions')

describe 'test-IO-Actions',->
  tmp_File_1      = null
  file_Contents_1 = null
  source_Folder   = null
  target_Folder   = null
  io_Actions      = null

  #tmp_File_2      = '_tmp_File_2.txt'.append_To_Process_Cwd_Path()
  #file_Contents_2 = (20).random_Letters()

  create_TestData = ()->
    file_Contents_1 = (20).random_Letters()
    tmp_File_1      = '_tmp_File_1.txt'.append_To_Process_Cwd_Path()
    source_Folder     = '_tmp_Folder'.append_To_Process_Cwd_Path()
    target_Folder   = source_Folder+"_copy"

    source_Folder   .folder_Create()         .assert_That_Folder_Exists()
    target_Folder.folder_Delete_Recursive().assert_Is_True()
    file_Contents_1.saveAs(tmp_File_1)
    source_Folder.path_Combine('A').folder_Create()
                 .path_Combine('A.txt').file_Write('A text')
    source_Folder.path_Combine('A/A').folder_Create()
                 .path_Combine('AA.txt').file_Write('AA text')
    source_Folder.path_Combine('B').folder_Create()
                 .path_Combine('B.txt').file_Write('B text')
    source_Folder.path_Combine('AB.txt').file_Write('AB test');
    source_Folder.assert_That_Folder_Exists()



  before ->
    io_Actions  = new IO_Actions();
    create_TestData()
    tmp_File_1.assert_File_Exists().file_Contents().assert_Is(file_Contents_1)
    source_Folder.path_Combine('A/A.txt').assert_File_Exists()
    source_Folder.path_Combine('B/B.txt').assert_File_Exists()
    source_Folder.path_Combine('AB.txt').assert_File_Exists()
    source_Folder.files_Recursive().assert_Size_Is(4)

  after ->
    tmp_File_1   .file_Delete().assert_Is_True()
    source_Folder.folder_Delete_Recursive().assert_Is_True()
    target_Folder.folder_Delete_Recursive().assert_Is_True()

  it 'constructor',->
    IO_Actions.assert_Is_Function().ctor().assert_Is_Object()
    io_Actions.assert_Is_Object()

  it 'copy_File', (done)->
    io_Actions.copy_File.assert_Is_Function()
    target_File_1 = tmp_File_1.append('.new')
    target_File_1.file_Delete().assert_Is_True()
    io_Actions.copy_File tmp_File_1, target_File_1, ->
      target_File_1.assert_File_Exists()
                  .file_Contents().assert_Is(file_Contents_1)

      target_File_1.file_Delete().assert_Is_True()
      done()

  it 'copy_Folder', (done)->
    io_Actions.copy_Folder source_Folder, target_Folder, ->
      target_Folder.assert_That_Folder_Exists()
      target_Folder.path_Combine('A/A.txt').assert_File_Exists()
      target_Folder.path_Combine('A/A/AA.txt').assert_File_Exists()
      target_Folder.path_Combine('B/B.txt').assert_File_Exists()
      target_Folder.path_Combine('AB.txt').assert_File_Exists()
      target_Folder.files_Recursive().assert_Size_Is(4)
      done()

