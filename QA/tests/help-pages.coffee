QA_TM_Design = require '../API/QA-TM_4_0_Design'
async        = require('async')
# this test suite contains all  all pages that we currently need to support for anonymous users (i.e. non logged in users)

describe 'help pages ', ->
  page = QA_TM_Design.create(before, after)

  help_Pages = []
  #@timeout(60000)             # set unit test timeout to 60s
  max             = 1         # number of pages to process
  takeScreenshots = false

  it 'find all help link', (done)->
    page.open '/help/index.html', (html,$)->
      help_Pages = ({href : link.attribs.href, title: $(link).html()} for link in $('#help-nav a'))
      help_Pages.assert_Size_Is(61)
      help_Pages[10].title.assert_Is("Managing Users")  #check a couple to see if they are still the ones we expect
      help_Pages[20].title.assert_Is("Using the Control Panel")
      help_Pages[30].title.assert_Is("Using the Search Function")
      help_Pages[40].title.assert_Is("Edit Article Metadata")
      help_Pages[50].title.assert_Is("How to Evaluate and What to Expect")
      done()


  it 'open all pages and check that titles match', (done)->
    @timeout(60000)
    index = 0
    open_Help_Page = (help_Page, next)->
      #console.log "[#{++index}/#{help_Pages.size()}] opening page: #{help_Page.title} - #{help_Page.href}"
      0.wait ->
        page.open help_Page.href,(html,$)->
          article_Title =$('#help-docs h2').html()
          if article_Title is 'Error fetching page from docs site'  # check if we are offline
            next()
            return
          article_Title.assert_Is(help_Page.title)                   # confirms title of loaded page matches link title
          $('#help-docs .lge-container').text().size().assert_Bigger_Than(100)   # confirms there is some text on the page
          next()

    async.eachSeries help_Pages.take(max), open_Help_Page, done


  if(takeScreenshots)
    it 'resize browser window', (done)->
      x      = 500;
      y      = 25;
      width  = 1024;
      height = 1000;
      page.window_Position x, y, width, height, ->
        done()

    it 'take Screenshot of all help pages', (done)->
      index = 0
      target_Pages = help_Pages.take(max)

      take_Screenshot = (target, next)->
        console.log "[#{++index}/#{target_Pages.size()}] taking screenshot of page: #{target.title}"
        page.open target.href, ->
          page.screenshot target.href, next

      async.eachSeries target_Pages, take_Screenshot, done
