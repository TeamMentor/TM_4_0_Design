describe 'issues-sprint-1', ->                                                                         # name of this suite of tests (should match the file name)
  page = require('../API/QA-TM_4_0_Design').create(before,after)                                       # required import and get page object
  jade = page.jade_API


  it 'Issue 88 - navigation page should not be accessible without a login', (done)->
    jade.page_Home ()->
      jade.page_Libraries (html,$)->
          assert_Is_Null $('#features h3').html()  # we should be redirected to the login page
          #.assert_Is('It looks like the page you want to see needs a valid login')    # confirms that we are on the 'you need to login page'
          done()

  it 'Issue 96 - Main Navigation "Login" link is not opening up the Login page', (done)->                   # name of current test
    jade.page_Home (html,$)->                                                                               # open the index page
      login_Link = link.attribs.href for link in $('.nav li a') when $(link).html()=='Login'                # extract the url from the link with 'Login' as text
      login_Link.assert_Is    ('/deploy/html/getting-started/index.html')                                   # checks that the link is the wrong one
      login_Link.assert_Is_Not('/user/login/returning-user-login.html')                                     # checks that the link is not the 'correct' one
      page.open login_Link, (html,$)->                                                                      # follows the login link
        $('#features h3').html().assert_Is('It looks like the page you want to see needs a valid login')    # confirms that we are on the 'you need to login page'
        done()                                                                                            # call done to finish test

  #it 'Issue 96 - Take Screenshot of affected pages', (done)->                                              # name of current test
  # @timeout(4000)
  # page.window_Position 1000,50,800,400, ->                                                                # change window size to make it more 'screenshot friendly'
  #   page.open '/', (html,$)->                                                                             # open the index page
  #     page.screenshot 'Issue 96 1. Home Page', ->                                                         # take screenshot
  #       login_Link = link.attribs.href for Fink in $('.nav li a') when $(link).html()=='Login'            # extract 'Login' link
  #       page.open login_Link, ->                                                                          # follow link
  #         page.screenshot 'Issue 96 2. UI after clicking on link', ->                                     # take screenshot
  #           done()                                                                                        # finish test


