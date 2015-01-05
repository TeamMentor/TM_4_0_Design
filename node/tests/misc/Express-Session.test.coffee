Express_Session = require('../../misc/Express-Session')

describe 'services | Express-Session.test', ()->
  it 'constructor',->
    using new Express_Session(),->
      @.filename.assert_Is('_session_Data')

