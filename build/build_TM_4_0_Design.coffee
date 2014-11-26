SCSS_Compiler   = require './source/SCSS-Compiler'
Jade_Compiler   = require './source/Jade-Compiler'
Coffee_Compiler = require './source/Coffee-Compiler'

describe 'build TM_4_0_Design |', ->

  root_Folder   = ".".append_To_Process_Cwd_Path()
  source_Folder = root_Folder.path_Combine("../source")
  scss_Folder   = source_Folder.path_Combine('scss')
  jade_Folder   = source_Folder
  coffee_Folder = root_Folder.path_Combine("../node")

  target_Folder  = "../static".append_To_Process_Cwd_Path()
  css_Folder     = target_Folder.path_Combine('css')
  js_Jade_Folder = target_Folder.path_Combine('jade_js')
  js_Coffee_Folder = target_Folder.path_Combine('coffee_js')

  scss_files    = ['normalize.css', 'custom-style.scss']

  it 'Clean target folders',->
    target_Folder   .folder_Delete_Recursive().assert_Is_True()
    target_Folder   .folder_Create()          .assert_That_Folder_Exists()
    css_Folder      .folder_Create()          .assert_That_Folder_Exists()
    js_Jade_Folder  .folder_Create()          .assert_That_Folder_Exists()
    js_Coffee_Folder.folder_Create()          .assert_That_Folder_Exists()

  it 'Compile scss files', (done)->
    scss_Files_In_Scss_Folder = (scss_Folder.path_Combine(scss_file) for scss_file in scss_files)

    new SCSS_Compiler().compile_Files_To scss_Files_In_Scss_Folder, css_Folder,done

  it 'Confirm that scss files compiled ok', (done)->
      for scss_file in scss_files
        css_Folder.path_Combine(scss_file.replace('.scss','.css')).assert_That_File_Exists()
      done()

  it 'Compile Jade files', (done)->
    @timeout(5000)
    jade_Compiler = new Jade_Compiler()
    jade_Compiler.options.ignore_Folders_Containing.add('user', 'articles', 'home','landing-pages','libraries','learning-paths', 'style-guide', 'search')
    jade_Compiler.compile_Folder_To jade_Folder, js_Jade_Folder, ->
      js_Jade_Folder.files_Recursive(".js").assert_Size_Is_Bigger_Than(3)
      done()


  it 'Compile Coffee files', (done)->
    coffee_Compiler = new Coffee_Compiler()
    coffee_Compiler.compile_Folder_To coffee_Folder, js_Coffee_Folder, ->
      js_Coffee_Folder.files_Recursive(".js").assert_Size_Is_Bigger_Than(3)
      done()
