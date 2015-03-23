Nedb            = null
Express_Session = null

class Session_Service

  dependencies: ()->
    Nedb            = require('nedb')
    Express_Session = require 'express-session'

  constructor: (options)->
    @.dependencies()
    @.options = options || {}
    @.filename = @.options.filename || './.tmCache/_sessionData' #"_session_Data"
    @.db = new Nedb(@.filename)
    Session_Service.prototype.__proto__ = Express_Session.Store.prototype;

  setup: (callback)=>
    @.session = Express_Session({ secret: '1234567890', key: 'tm-session'
                                , saveUninitialized: true , resave: true
                                , cookie: { path: '/' , httpOnly: true , maxAge: 365 * 24 * 3600 * 1000 }
                                , store: @ })
    @.db.loadDatabase ->
      callback() if callback
    @


  #TM Specific methods
  session_Data: (callback)=>
    @.db.find {}, (err,sessionData)=>
      callback sessionData

  viewed_Articles: (callback)=>
    @.db.find {}, (err,sessionData)=>
      viewed_Articles = []
      if sessionData
          for session in sessionData
              if session.data.recent_Articles
                  for recent_article in session.data.recent_Articles
                      viewed_Articles.add(recent_article)
      callback viewed_Articles

  users_Searches: (callback)=>
    @.db.find {}, (err,sessionData)=>
      users_Searches = []
      if sessionData
          for session in sessionData
              if session.data.user_Searches
                for user_Search in session.data.user_Searches
                  if user_Search.results
                    users_Searches.push(user_Search)
        callback users_Searches

  top_Articles: (callback)=>
    @.viewed_Articles (data)->
      if (is_Null(data))
          callback []
          return
      results = {}
      for item in data
          results[item.id] ?= { href: "/article/#{item.id}", title: item.title, weight: 0}
          results[item.id].weight++
      results = (results[key] for key in results.keys())

      results = results.sort (a,b)-> a.weight - b.weight

      callback results.reverse()

  top_Searches: (callback)=>
    @.users_Searches (data)->
      if (is_Null(data))
          callback []
          return
      results = {}
      for item in data
        if item.title
          results[item.id] ?= { title: item.title, weight: 0}
          results[item.id].weight++
      results = (results[key] for key in results.keys())

      results = results.sort (a,b)-> a.weight - b.weight

      callback results.reverse()

  user_Data: (session,callback)=>
    data = {}
    data.username        = session.username

    data.recent_Searches = []
    if session.user_Searches
      for user_Search in (session.user_Searches.reverse())
        if user_Search.results > 0 and data.recent_Searches.not_Contains(user_Search.title)
          data.recent_Searches.push user_Search.title
      data.recent_Searches = data.recent_Searches.slice(0,3)
      session.user_Searches.reverse()   # restore original order

    data.recent_Articles = []
    mapped_Articles = {}
    if session.recent_Articles
      for recent_Article in session.recent_Articles
        if not mapped_Articles[recent_Article.id]
          data.recent_Articles.push recent_Article
          mapped_Articles[recent_Article.id] = recent_Article
      data.recent_Articles = data.recent_Articles.slice(0,3)

    @.top_Searches (top_Searches)=>
      data.top_Searches = top_Searches.slice(0,3)

      @.top_Articles (top_Articles)=>
        data.top_Articles = top_Articles.slice(0, 3)
        callback data

      #topResults = []
      #topResults.add(results.pop()).add(results.pop())
      #          .add(results.pop()).add(results.pop())
      #          .add(results.pop())


#based on code from https://github.com/louischatriot/connect-nedb-session/blob/master/index.js

Session_Service.prototype.get =  (sid, callback)->
  this.db.findOne { sid: sid },  (err, sess)->
    if (err)
      return callback(err);
    if (!sess)
      return callback(null, null);

    return callback(null, sess.data);

Session_Service::set = (sid, data, callback)->
  this.db.update { sid: sid }, { sid: sid, data: data }, { multi: false, upsert: true },  (err)->
    return callback(err)

Session_Service.prototype.destroy = (sid, callback)->
  this.db.remove { sid: sid }, { multi: false }, (err)->
    return callback(err);

module.exports = Session_Service



