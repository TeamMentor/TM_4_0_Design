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