QA_TM_Design = require '../API/QA-TM_4_0_Design'

describe 'user-stories', ->
  page = QA_TM_Design.create();
  before (done)-> page.before done

  @timeout 0

  beforeEach ()->
    page.open_Delay = 0


  it 'User should navigate site and find login link', (done)->
    page.open '/', ->
      page.click 'about', ->
        page.click 'help', ->
          page.click 'getting-started', ->              # Bug: Login link should show login page
            page.click 'returning-user-login.html',->
              done()
