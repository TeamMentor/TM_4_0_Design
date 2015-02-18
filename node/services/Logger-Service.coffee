NeDB        = null  # Helper class for [NeDB](https://github.com/louischatriot/nedb/) support
Persistence = null
model       = null
customUtils = null


class Logger_Service

  constructor: (options)->
    NeDB         = require 'nedb'
    Persistence  = require 'nedb/lib/persistence'
    model        = require('nedb/lib/model')
    customUtils  = require('nedb/lib/customUtils')
    @options     = options || {}
    @log_Folder  = @options.log_Folder || './.logs'
    @persistence = null

  log_File: ()=>
    today = new Date().toDateString().replace(/\s/g,'-')
    @log_Folder.path_Combine("#{today}.log")

  setup: ()=>
    @log_Folder.create_Dir()

    dbOptions =
                filename    : @log_File()
                inMemoryOnly: false
                autoload    : false

    @persistence = new Persistence({ db: dbOptions });
    @

  write: (data,callback)=>
    data =  [data] if not (data instanceof Array)

    copiedData = []

    for item in data
      itemCopy = model.deepCopy(item)
      model.checkObject(itemCopy)
      copiedData.push(itemCopy)

    #for now don't add unique id to log entries
    #copiedData.forEach (item)-> item._id = customUtils.uid(16)
    @persistence.persistNewState copiedData, callback
    @

  log: (message, callback)=>
    time = new Date().toJSON() #.after('T')   # was causing probs in heroku
    entry = {when: time, entry: message}
    @write(entry, callback)

module.exports = Logger_Service
