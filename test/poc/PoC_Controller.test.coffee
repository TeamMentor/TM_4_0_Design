PoC_Controller   = require '../../src/poc/PoC-Controller'
supertest        = require 'supertest'
express          = require 'express'
cheerio          = require 'cheerio'
path             = require 'path'

describe '| poc | Controller-PoC.test |' ,->

  it 'constructor',->
    using new PoC_Controller() ,->
      @.dir_Poc_Pages.assert_Folder_Exists()
                     .assert_Contains "source#{path.sep}jade#{path.sep}__poc"

  it 'register_Routes', ()->
    routes     = {}
    auth_Check = null
    express_Service =
      app:
        get: (path,target)-> routes[path] = target

    using new PoC_Controller({ express_Service: express_Service}).register_Routes() ,->
      routes.assert_Is
        '/poc*'                     : @.check_Auth
        '/poc'                      : @.show_Index
        '/poc/filters:page'         : @.show_Filters
        '/poc/filters:page/:filters': @.show_Filters
        '/poc/:page'                : @.show_Page

  it 'check_Auth (anonymous)', (done)->
    res =
      status: (value)->
        value.assert_Is 403
        @
      redirect: (value)->
        value.assert_Is '/guest/404'
        done()

    new PoC_Controller().check_Auth(null,res,null)

  it 'check_Auth (user)', (done)->
    req = session: username : 'abc'
    new PoC_Controller().check_Auth(req, null, done)

  it 'jade_Files', (done)->
    using new PoC_Controller() ,->
      files = @.jade_Files().assert_Not_Empty()
      @.dir_Poc_Pages.files_Recursive().assert_Contains files
      done()

  it 'map_Files_As_Pages', (done)->
    using new PoC_Controller() ,->
      pages      = @.map_Files_As_Pages()
      mappings   = {}
      mappings[page.name]=page.link for page in pages
      for file in @.jade_Files()
        fileName = file.file_Name_Without_Extension()
        mappings[fileName].assert_Is "/poc/#{fileName}"
      mappings['Articles'].assert_Is '/articles'
      done()

  it 'show_Index', (done)->
    req = {}
    res =
      status: (value)->
        value.assert_Is 200
        @
      send: (html)->
        html.assert_Contains ['Article' , 'poc-pages', 'top-articles']
        done()

    new PoC_Controller().show_Index(req,res)

  it 'show_Page (good link)', (done)->
    express_Service = session_Service: users_Searches: (callback) -> callback []
    using new PoC_Controller({ express_Service: express_Service}), ->

      req = params : page : @.map_Files_As_Pages().last().name
      res =
        status: (value)->
          value.assert_Is 200
          @
        send: (html)->
          html.assert_Is_String()
          done()

      @.show_Page(req,res)

  it 'show_Page (bad link)', (done)->
    using new PoC_Controller(), ->

      req = params : page : 'aaaaabbbb'
      res =
        status: (value)->
          log value
          @
        redirect: (target)->
          target.assert_Is '/guest/404'
          done()

      @.show_Page(req,res)

  #it  'render_Jade', (done)-> # this is already tested by the previous method

  describe 'using Express |', ->
    it 'check Auth redirect', (done)->
      app = new express()
      express_Service = app : app
      new PoC_Controller({express_Service:express_Service}).register_Routes()
      supertest(app)
        .get('/poc')
        .end (err, response, html)->
          response.text.assert_Is 'Moved Temporarily. Redirecting to /guest/404'
          done()
