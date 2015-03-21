require 'fluentnode'
Jade_Controller = require('../../src/controllers/Jade-Controller')
cheerio = require 'cheerio'

describe '| controllers | Jade-Controller.test.js |', ()->

  describe 'render mixin', ->
    mixin_File   = null
    extends_File = null
    res_Mock     = null
    req_Mock     = null
    mixin_Name   = 'an-mixin-method'
    mixin_Code   = "mixin #{mixin_Name}\n" +
                   "  h3 static_h3 (in mixin)\n" +
                   "  h2= dynamic_h2 "
    extends_Code = "h1 static h1 (in extends)\n" +
                   "block content \n"
    dynamic_h2   = 'from test_'.add_5_Random_Letters()

    before ->
      mixin_File   = ".".temp_Name_In_Folder().append('.jade')
      extends_File = mixin_File.replace('.jade','_extends.jade')

      mixin_File   .file_Write(mixin_Code  ).assert_File_Contents(mixin_Code)
      extends_File .file_Write(extends_Code).assert_File_Contents(extends_Code)

    assert_On_Send =
      (next)->
        (html)->
          $ = cheerio.load(html)
          $('h1').html().assert_Is('static h1 (in extends)')
          $('h2').html().assert_Is(dynamic_h2)
          $('h3').html().assert_Is('static_h3 (in mixin)')
          next()

    using_Jade_Controller = (next, callback)=>
      using new Jade_Controller(),->
        @.res = send: assert_On_Send(next)
        @.req =
                params:
                  file: mixin_File.file_Name_Without_Extension()
                  mixin:mixin_Name
        @.jade_Service.mixins_Folder = mixin_File.parent_Folder()
        @.jade_Service.mixin_Extends = extends_File.file_Name()

        callback.apply(@)

    after ->
      mixin_File.assert_File_Deleted()
      extends_File.assert_File_Deleted()


    it 'renderMixin', (done)->
      using_Jade_Controller done, ()->
        @.renderMixin({dynamic_h2 : dynamic_h2})

    it 'renderMixin_GET (valid params)', (done)->
      dynamic_h2 = 'now_on_get_'.add_5_Letters()
      using_Jade_Controller done, ()->
        @.req.query = {dynamic_h2 : dynamic_h2}
        @.renderMixin_GET({dynamic_h2 : dynamic_h2})

    it 'renderMixin_GET (no params)', (done)->
      dynamic_h2 = ''
      using_Jade_Controller done, ()->
        @.req.query = {}
        @.renderMixin_GET({dynamic_h2 : dynamic_h2})

    it 'renderMixin_GET (with view model)', (done)->
      viewModel_Data = { resultsTitle : 'AAAA'}.json_Str()
      dynamic_h2 = ''
      using_Jade_Controller done, ()->
        @.req.query = {viewModel : viewModel_Data}
        @.renderMixin_GET({dynamic_h2 : dynamic_h2})

    it 'renderMixin_POST (valid params)', (done)->
      dynamic_h2 = 'now_on_post_'.add_5_Letters()
      using_Jade_Controller done, ()->
        @.req.body = {dynamic_h2 : dynamic_h2}
        @.renderMixin_POST()

    it 'renderMixin_POST (no params)', (done)->
      dynamic_h2 = ''
      using_Jade_Controller done, ()->
        @.req.body = {}
        @.renderMixin_POST()

  describe 'render file',->

    it 'renderFile', (done)->
      req =
            params: { file: 'jade_guest_about'}

      res =
            send: (html)->
              html.assert_Contains('<li><a id="nav-about" href="/guest/about.html">About</a></li>')
              done()

      using new Jade_Controller(req, res),->
        @.renderFile_GET()

