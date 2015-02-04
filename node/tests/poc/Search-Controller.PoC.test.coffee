Search_Controller_PoC = require '../../poc/Search-Controller.PoC'

describe 'poc | Search-Controller.PoC.test' ,->
  it 'constructor',->
    using new Search_Controller_PoC('a','b') ,->
      @.req.assert_Is 'a'
      @.res.assert_Is 'b'
