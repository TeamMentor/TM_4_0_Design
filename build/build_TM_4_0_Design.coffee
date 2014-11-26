SCSS_Compiler = require './source/SCSS-Compiler'

describe 'build TM_4_0_Design |', ->

  target_Folder = "../static".append_To_Process_Cwd_Path()
  css_Folder    = target_Folder.path_Combine('css')
  source_Folder = "../source".append_To_Process_Cwd_Path()
  scss_Folder   = source_Folder.path_Combine('scss')

  scss_files    = ['normalize.css', 'custom-style.scss']

  it 'Clean target folders',->
    target_Folder.folder_Delete_Recursive().assert_Is_True()
    target_Folder.folder_Create()          .assert_That_Folder_Exists()
    css_Folder   .folder_Create()          .assert_That_Folder_Exists()

  it 'Compile scss files', (done)->
    scss_Files_In_Scss_Folder = (scss_Folder.path_Combine(scss_file) for scss_file in scss_files)

    new SCSS_Compiler().compile_Files_To scss_Files_In_Scss_Folder, css_Folder,done

  it 'Confirm that scss files compiled ok', (done)->
      for scss_file in scss_files
        css_Folder.path_Combine(scss_file.replace('.scss','.css')).assert_That_File_Exists()
      done()

