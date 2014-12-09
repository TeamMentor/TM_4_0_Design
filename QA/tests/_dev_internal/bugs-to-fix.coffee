QA_TM_Design = require '../../API/QA-TM_4_0_Design'

#skip all tests since this leave the test run in an unstable mode
return

describe.only 'bugs-to-fix ', ->
  page = QA_TM_Design.create()
  before (done)->
    page.before ->
      page.add_Extra_Error_Handling ->
        done()

  it 'This help page crashes chrome (without the call to Page.add_Extra_Error_Handling()', (done)->
    console.log('before')
    page.chrome.open 'http://127.0.0.1:1337/help/c7dfdf96-39b4-48c2-93d6-684b5626ec01',->
      console.log('where never gete here')
      done()