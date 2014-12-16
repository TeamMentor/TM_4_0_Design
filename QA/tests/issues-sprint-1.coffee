describe 'issues-sprint-1', ->                                                                         # name of this suite of tests (should match the file name)
  page = require('../API/QA-TM_4_0_Design').create(before,after)                                       # required import and get page object
  jade = page.jade_API


  it 'Issue 88 - navigation page should not be accessible without a login', (done)->
    jade.page_Home ()->
      jade.page_Libraries (html,$)->
          assert_Is_Null $('#features h3').html()  # we should be redirected to the login page
          #.assert_Is('It looks like the page you want to see needs a valid login')    # confirms that we are on the 'you need to login page'
          done()

  it.only 'Issue 117 - Getting Started Page is blank', (done)->
    jade.page_Main_Page ->
      page.click 'START YOUR FREE TRIAL TODAY', (html)->
        html.assert_Is('<html><head></head><body></body></html>')                        # confirm empty html page
        jade.page_Main_Page ->
          page.click 'SEE FOR YOURSELF', (html)->
            html.assert_Is('<html><head></head><body></body></html>')
            done()


  #it 'Issue 96 - Take Screenshot of affected pages', (done)->                                              # name of current test
  # @timeout(4000)
  # page.window_Position 1000,50,800,400, ->                                                                # change window size to make it more 'screenshot friendly'
  #   page.open '/', (html,$)->                                                                             # open the index page
  #     page.screenshot 'Issue 96 1. Home Page', ->                                                         # take screenshot
  #       login_Link = link.attribs.href for Fink in $('.nav li a') when $(link).html()=='Login'            # extract 'Login' link
  #       page.open login_Link, ->                                                                          # follow link
  #         page.screenshot 'Issue 96 2. UI after clicking on link', ->                                     # take screenshot
  #           done()                                                                                        # finish test


