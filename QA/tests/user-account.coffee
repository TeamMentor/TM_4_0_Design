describe 'user-account', ->
  page = require('../API/QA-TM_4_0_Design').create(before,after)
  jade = page.jade_API

  it 'login_As_QA , session_Cookie', (done)->
    jade.clear_Session  (err, data)->
      jade.login_As_QA ->
        jade.session_Cookie (cookie)->
          cookie.name.assert_Is('connect.sid')
          cookie.value.size().assert_Bigger_Than(30)
          #console.log cookie
          done()

  it 'clear_Session , session_Cookie', (done)->
    jade.clear_Session  (err, data)->
      jade.session_Cookie (cookie)->
        assert_Is_Null(cookie)
        done()

  it 'Login fail', (done)->
    jade.login 'aaaa'.add_5_Random_Letters(),'bbbb',  (html, $) ->
      $('.alert').html().assert_Is('Login failed, please try again :(')
      done()

  it 'User Sign Up (with weak password)',(done)->
    @timeout(0)
    username = 'tm_qa_'.add_5_Random_Letters()
    password = '**tm**qa**USER'
    email    = "#{username}@teammentor.net"
    jade.user_Sign_Up username, password, email, ->
      page.chrome.url (url)->
        url.assert_Contains('/guest/sign-up-OK.html')
        page.html (html,$)->
          $('h3').html().assert_Is('Login')
          jade.login username, password, ->
            page.chrome.url (url)->
              url.assert_Contains('user/main.html')
              done()

  it 'User Sign Up Fail',(done)->
    @timeout(0)
    assert_User_Sign_Up_Fail = (username, password, email, next)->
      jade.user_Sign_Up username, password, email, ->
        page.chrome.url (url)->
          url.assert_Contains('/guest/sign-up-Fail.html')
          next()

    randomUser  = 'abc_'.add_5_Random_Letters();
    randomEmail = "#{randomUser}@teammentor.net"

    assert_User_Sign_Up_Fail randomUser, 'existing email', 'dcruz@securityinnovation.com', ->
      assert_User_Sign_Up_Fail 'dinis', 'existing user', randomEmail, ->
        assert_User_Sign_Up_Fail '', 'no username', randomEmail, ->
          assert_User_Sign_Up_Fail randomUser, 'no email', '', ->
            assert_User_Sign_Up_Fail randomUser + 'no pwd', '', randomEmail, ->
              #note that at the moment there is no check for weak passwords
              done()

  it 'User Sign Up Fail (different passwords)',(done)->

    randomUser  = 'abc_'.add_5_Random_Letters();
    randomEmail = "#{randomUser}@teammentor.net"
    pwd1 = "aaaa"
    pwd2 = "bbbb"
    jade.page_Sign_Up (html, $)=>
      code = "document.querySelector('#new-user-username').value='#{randomUser}';
                                  document.querySelector('#new-user-password').value='#{pwd1}';
                                  document.querySelector('#new-user-confirm-password').value='#{pwd2}';
                                  document.querySelector('#new-user-email').value='#{randomEmail}';
                                  document.querySelector('#btn-sign-up').click()"
      page.chrome.eval_Script code, =>
        page.wait_For_Complete (html, $)=>
          page.chrome.url (url)->
            url.assert_Contains('/guest/sign-up-Fail.html')
          done()

  #add issue that new users can be created with weak pwds (from jade)