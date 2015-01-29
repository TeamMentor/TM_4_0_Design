Search_Controller_PoC = require '../../poc/Search-Controller.PoC'

describe 'poc | Search-Controller.PoC.test' ,->
  it 'constructor',->
    using new Search_Controller_PoC('a','b') ,->
      @.req.assert_Is 'a'
      @.res.assert_Is 'b'
      @.md_Render.assert_Is_Function()

  it 'rm_Render', (done)->
    req =
      body:
        md_text: 'abc **aaa** dfg'

    res =
      send: (html)->
        html.assert_Contains '<strong>aaa</strong>'
        done()

    using new Search_Controller_PoC(req,res),->
      @.md_Render()
