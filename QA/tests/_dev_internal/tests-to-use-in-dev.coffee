return
QA_TM_Design = require '../../API/QA-TM_4_0_Design'

describe '_dev_internal| tests-to-user-in-dev ', ->
  page = QA_TM_Design.create(before, after)
  jade = page.jade_API;

  it 'open page to work on', (done)->
    #jade.page_Login ->
    jade.login '', '', (html,$)->
      $('.alert').html().assert_Is('Login failed')
      done()

