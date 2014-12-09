require 'fluentnode'
require('../node_modules/node-webkit-repl/src/extra_fluentnode.coffee')
NodeWebKit_Service = require('node-webkit-repl')

class QA_TM_4_0_Design

  constructor: ()->
    @nodeWebKit  = new NodeWebKit_Service(57777)
    nodeWebKit   = @nodeWebKit
    @tm_Server   = 'http://localhost:1337'
    @chrome      = null
    @open_Delay  = 0

  before: (done)=>
    if not (@chrome is null)
      done()
      return;
    @nodeWebKit.path_App   = '/API'.append_To_Process_Cwd_Path()
    @nodeWebKit.chrome.url_Json.GET (data)=>
      if (data is null)
        @nodeWebKit.start =>
          @chrome = @nodeWebKit.chrome
          #@nodeWebKit.open_Index ->
          @add_Extra_Error_Handling done
      else
        @nodeWebKit.chrome.connect =>
          @chrome = @nodeWebKit.chrome
          @add_Extra_Error_Handling done


  after: (done)->
    @nodeWebKit.stop =>
      done()

  open: (url, callback)=>
    @chrome.open @tm_Server + url, =>
      @open_Delay.wait =>
        @html(callback)

  html: (callback)=>
      @chrome.html (html,$) =>
        callback(html,@add_Cheerio_Helpers($))

  show: (callback)-> @nodeWebKit.show(callback)

  wait_For_Complete: (callback)=>
    @chrome.page_Events.on 'loadEventFired', ()=>
      @html callback

  add_Cheerio_Helpers: ($)=>
    $.body = $('body').html()
    $.title = $('title').html()
    $.links = ($.html(link) for link in $('a'))
    $

  screenshot: (name, callback)=>
    safeName = name.replace(/[^()^a-z0-9._-]/gi, '_') + ".png"
    png_File = "./_screenshots".append_To_Process_Cwd_Path().folder_Create()
                               .path_Combine(safeName)

    @chrome._chrome.Page.captureScreenshot (err, image)->
      require('fs').writeFile png_File, image.data, 'base64',(err)->
        callback()

  window_Position: (x,y,width,height, callback)=>
    @nodeWebKit.open_Index ()=>
      @chrome.eval_Script "curWindow = require('nw.gui').Window.get();
                           curWindow.x=#{x};
                           curWindow.y=#{y};
                           curWindow.width=#{width};
                           curWindow.height=#{height};
                           ", callback

  click: (href, callback)->
    @chrome.eval_Script "document.querySelector('a[href*=\"#{href}\"]').click()", =>
      @wait_For_Complete =>
        @open_Delay.wait =>
          callback()

  add_Extra_Error_Handling: (callback)->
    @nodeWebKit.open_Index =>
      code = "process.on('uncaughtException', function(err) { alert(err);});";
      @chrome.eval_Script code, (err,data)=>
        callback()

singleton  = null

QA_TM_4_0_Design.create = (before)->
  #return new QA_TM_4_0_Design()              # uncomment this if a new instance is needed per test (and the 'after' mocha event is set)

  if singleton is null
    singleton = new QA_TM_4_0_Design()
  if typeof(before) == 'function'
    before (done)-> singleton.before done
  return singleton

module.exports = QA_TM_4_0_Design