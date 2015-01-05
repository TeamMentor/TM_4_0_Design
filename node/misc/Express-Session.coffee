Nedb    = require('nedb')

class Express_Session
  constructor: (options)->
    @.options = options || {}
    @.filename = @.options.filename || '_session_Data'
    @.db = new Nedb(@.filename);

  setup: (session,callback)=>
    @.db.loadDatabase ()->
      callback() if callback

    Express_Session.prototype.__proto__ = session.Store.prototype; #   Inherit from Connect's session store

Express_Session.prototype.get = (sid, callback)=>
  @.db.findOne { sid: sid },  (err, sess)=>
    if (err)
      return callback(err);
    if (!sess)
      return callback(null, null);

    return callback(null, sess.data)

Express_Session.prototype.set = (sid, data, callback)=>
  @.db.update { sid: sid }, { sid: sid, data: data }, { multi: false, upsert: true },  (err)=>
    return callback(err)


Express_Session.prototype.destroy = (sid, callback)=>
  @.db.remove { sid: sid }, { multi: false }, (err)=>
    return callback(err)

module.exports = Express_Session