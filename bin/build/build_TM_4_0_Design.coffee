Coffee_Compiler = require './source/Coffee-Compiler'
IO_Actions      = require './source/IO-Actions'
Jade_Compiler   = require './source/Jade-Compiler'
SCSS_Compiler   = require './source/SCSS-Compiler'


describe.only 'build TM_4_0_Design |', ->

  root_Folder     = __dirname.path_Combine(['..','..'])
  source_Assets   = root_Folder.path_Combine(['deploy','assets'])
  source_Coffee   = root_Folder.path_Combine("node")
  source_Fonts    = root_Folder.path_Combine("deploy/fonts")
  source_Scss     = root_Folder.path_Combine('source/scss')
  source_Jade     = root_Folder.path_Combine('source')

  build_Folder    = root_Folder.path_Combine(".")
  build_Assets    = build_Folder.path_Combine('assets')
  build_Css       = build_Folder.path_Combine('css')
  build_Fonts     = build_Folder.path_Combine('fonts')
  build_Js_Jade   = build_Folder.path_Combine('jade_js')
  build_Js_Coffee = build_Folder.path_Combine('coffee_js')

  scss_files    = ['app.scss','custom-style.scss','custom-style-flare.scss','ie.scss', 'normalize.css', 'print.scss', 'screen.css']

  coffee_Compiler = new Coffee_Compiler()
  io_Actions      = new IO_Actions()
  jade_Compiler   = new Jade_Compiler()

  log build_Folder
  return
  it 'Clean target folders',->
    build_Folder   .folder_Delete_Recursive().assert_Is_True()
    build_Folder   .folder_Create()          .assert_That_Folder_Exists()
    build_Assets   .folder_Create()          .assert_That_Folder_Exists()
    build_Css      .folder_Create()          .assert_That_Folder_Exists()
    build_Fonts    .folder_Create()          .assert_That_Folder_Exists()
    build_Js_Jade  .folder_Create()          .assert_That_Folder_Exists()
    build_Js_Coffee.folder_Create()          .assert_That_Folder_Exists()

  it 'Compile scss files', (done)->
    scss_Files_In_Scss_Folder = (source_Scss.path_Combine(scss_file) for scss_file in scss_files)
    new SCSS_Compiler().compile_Files_To scss_Files_In_Scss_Folder, build_Css,done


  it 'Compile Jade files', (done)->
    @timeout(20000)
    jade_Compiler.options.ignore_Folders_Containing.add('user', 'articles', 'home','libraries','learning-paths', 'style-guide', 'search')
    jade_Compiler.compile_Folder_To source_Jade, build_Js_Jade, ->
      done()

  it 'Compile Coffee files', (done)->
    coffee_Compiler.compile_Folder_To source_Coffee, build_Js_Coffee, ->
      for js_File in source_Coffee.files_Recursive(".js")
        io_Actions.copy_File(js_File, js_File.replace(source_Coffee, build_Js_Coffee))
      done()


  it 'Copy assets', (done)->
    io_Actions.copy_Folder source_Assets, build_Assets, ->
      io_Actions.copy_Folder source_Fonts, build_Fonts, ->
        done()

  return
  it 'Confirm files compiled/copied ok', (done)->
    for scss_file in scss_files
      build_Css.path_Combine(scss_file.replace('.scss','.css')).assert_That_File_Exists()
    build_Js_Jade  .files_Recursive(".js")   .assert_Size_Is_Bigger_Than(3)
    build_Js_Coffee.files_Recursive(".js")   .assert_Size_Is_Bigger_Than(14)
    build_Js_Coffee.path_Combine('Config.js').assert_File_Exists()
    build_Js_Coffee.path_Combine('server.js').assert_File_Exists()
    done()

