#return
QA_TM_Design = require '../../API/QA-TM_4_0_Design'

describe.only '_dev_internetl | tests-to-user-in-dev ', ->
  page = QA_TM_Design.create(before, after)
  jade = page.jade_API;

  it 'open page to work on', (done)->
    jade.login '', '', (html,$)->
      $('.alert').html().assert_Is('Login failed')
      done()

