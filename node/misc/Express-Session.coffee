Nedb = null

class Express_Session
  constructor: (options, cb)->

    Nedb    = require('nedb')

    callback = cb ||  ()->
    @.options = options || {}
    @.filename = @.options.filename || "_session_Data"
    @.db = new Nedb(@.options.filename);
    @.db.loadDatabase(callback)
    if (@.options.session)
      Express_Session.prototype.__proto__ = options.session.Store.prototype;


Express_Session.prototype.get =  (sid, callback)->
  this.db.findOne { sid: sid },  (err, sess)->
    if (err)
      return callback(err);
    if (!sess)
      return callback(null, null);

    return callback(null, sess.data);

Express_Session::set = (sid, data, callback)->
  this.db.update { sid: sid }, { sid: sid, data: data }, { multi: false, upsert: true },  (err)->
    return callback(err)

Express_Session.prototype.destroy = (sid, callback)->
  this.db.remove { sid: sid }, { multi: false }, (err)->
    return callback(err);

module.exports = Express_Session



#based on code from https://github.com/louischatriot/connect-nedb-session/blob/master/index.js