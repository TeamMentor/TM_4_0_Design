describe 'issues-sprint-1', ->                                                                         # name of this suite of tests (should match the file name)
  page = require('../API/QA-TM_4_0_Design').create(before,after)                                       # required import and get page object
  jade = page.jade_API


  it 'Issue 105 - New users can be created with Weak Passwords', (done)->
    assert_Weak_Pwd_Fail = (password, expectFail, next)->
      randomUser  = 'abc_'.add_5_Random_Letters();
      randomEmail = "#{randomUser}@teammentor.net"
      jade.user_Sign_Up randomUser, password, randomEmail, (html , $)->
        if expectFail
          $('h3').html().assert_Is('Sign Up')
          next()
        else
          $('h3').html().assert_Is('Login')
          jade.login randomUser,password, (html,$)->
            page.chrome.url (url)->
              url.assert_Contains('/user/main.html')
              next()

    @timeout(10000)

    assert_Weak_Pwd_Fail "", true, ->
      assert_Weak_Pwd_Fail  "123", false, ->   # this should fail to create an account
        #assert_Weak_Pwd_Fail  "!!123", ->
        done()

  it 'Issue 151 - Add asserts for new Login page content ', (done)->
    jade.page_Login (html,$)->
      $('#summary h1').html().assert_Is('Security Risk. Understood.')
      $('#summary p').html().assert_Is('TEAM Mentor was created by developers for developers using secure coding standards, code snippets and checklists built from 10+ years of targeted security assessments for Fortune 500 organizations.')
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


