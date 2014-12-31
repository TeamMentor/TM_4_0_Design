auth = require('../../middleware/auth')

describe 'auth.test',->

  it 'test exports',->
    auth.assert_Is_Object()
    auth.checkAuth.assert_Is_Function()
    auth.mappedAuth.assert_Is_Function()

  it 'checkAuth (all null)', (done)->
    auth.checkAuth(null,null, done,null)

  it 'checkAuth (valid session username)', (done)->
    next = ()->
      done()
    req = { session: { username: 'abc'} }
    auth.checkAuth(req,null, next,null)

  it 'checkAuth (no session username)', (done)->

    send = (html)->
      html.assert_Contains('You need to login to see that page :)')
      done()
    res = {}
    res.status = (value)->
                    value.assert_Is(403)
                    res
    res.send   = send
    config = null
    req = { session: { username: undefined} }
    auth.checkAuth(req,res, null,config)