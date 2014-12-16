return
QA_TM_Design = require '../../API/QA-TM_4_0_Design'

describe.only '_dev_internal| tests-to-user-in-dev ', ->
  page = QA_TM_Design.create(before, after)
  jade = page.jade_API;

  xit '/user/login/returning-user-login.html', (done)->
    page.open '/user/login/returning-user-login.html', (html, $)->
      console.log html
      done()

  xit 'open page to work on', (done)->
    jade.page_Login ->
      #page.field '#new-user-username', 'asd', (values)->
      jade.login 'user', 'a', (html,$)->
        done()

  it.only 'check cookie', (done)->
    jade.page_About ->

      #page.eval 'document.cookie ="abc=123"'
      page.chrome.cookies (value)->
        console.log value
        done()

