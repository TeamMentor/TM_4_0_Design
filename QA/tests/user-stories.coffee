QA_TM_Design = require '../API/QA-TM_4_0_Design'

describe 'user-stories', ->
  page = QA_TM_Design.create(before, after)

  #@timeout 0

  beforeEach ()->
    page.open_Delay = 0

  it 'User should navigate site and find login link', (done)->
    page.open '/', ->
      page.click 'ABOUT', ->
        page.click 'HELP', ->
          page.click 'LOGIN', ->
            page.click 'LOGIN',->
              done()