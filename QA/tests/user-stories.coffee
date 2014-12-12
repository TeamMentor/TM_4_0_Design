QA_TM_Design = require '../API/QA-TM_4_0_Design'

describe 'user-stories', ->
  page = QA_TM_Design.create(before, after)
  jade = page.jade_API

  #@timeout 0

  beforeEach ()->
    page.open_Delay = 0

  it 'User should navigate site and find login link', (done)->
    jade.clear_Session ->
      page.open '/', ->
        page.click 'ABOUT', ->
          page.click 'HELP', ->
            page.click 'LOGIN', ->
              page.click 'LOGIN',->
                done()