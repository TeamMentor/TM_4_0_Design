Logger_Service = require('./../../services/Logger-Service')

describe 'Logger-Service.test', ->

  it 'constructor()',->
    using new Logger_Service(),->
      @options.assert_Is({})
      @log_Folder.assert_Is('./.logs')

  it 'constructor(options)',->
    value = 'aaaa'
    options = { log_Folder: value}
    using new Logger_Service(options), ->
      @options   .assert_Is(options)
      @log_Folder.assert_Is(value)

  describe 'methods',->
    logger_Service = null

    before ->
      options      = { log_Folder: './_tmp_Logs'}
      logger_Service = new Logger_Service(options)
      logger_Service.setup()

    after ->
      logger_Service.log_Folder.folder_Delete_Recursive()
      .assert_True()

    it 'log_File',->
      logger_Service.log_File().assert_Contains(new Date().toDateString().split(' '))
                             .assert_Contains('.log')

    it 'setup', ->
      using logger_Service.log_Folder,->
        @.assert_Folder_Exists()
        @.files().assert_Size_Is(0)
      using logger_Service.persistence,->
        @.assert_Is_Object()
        @.filename    .assert_Is(logger_Service.log_File())
        @.db.inMemoryOnly.assert_Is_False()
        @.db.autoload    .assert_Is_False()

    it 'write(object)', (done)->
      entry = {entry : 'this is an entry as object'}
      logger_Service.write entry, ->
        logger_Service.log_File().load_Json().assert_Is(entry)
        done()

    it 'write(string)', (done)->
      entry = 'this is an entry as string'
      logger_Service.write entry, ->
        logger_Service.log_File().file_Contents().split('\n')
                               .second()
                               .assert_Is(JSON.stringify(entry))
        done()

    it 'write(array)', (done)->
      entry = ['item1','item2']
      logger_Service.write entry, ->
        items = logger_Service.log_File().file_Contents().split('\n')
        items.third() .assert_Is('"item1"')
        items.fourth().assert_Is('"item2"')
        done()
    it 'log', (done)->
      logger_Service.log_File().file_Delete().assert_True()
      message = 'log message'
      logger_Service.log message, ->
        logEntry = logger_Service.log_File().load_Json()
        logEntry.when   .assert_Contains(new Date().toJSON().after('T').before_Last('.'))
        logEntry.entry.assert_Is(message)
        done()

return





describe.only 'NeDB-Service.test', ->
  path_Db = './test.db'
  db = null
  persistence = null

  it 'load db',->
    dbOptions = {
                  filename    : path_Db
                  inMemoryOnly: false
                  autoload    : false
                }

    persistence = new Persistence({ db: dbOptions });

  it 'add docs', (done)->
    docs         = [ { "name": "value_".add_5_Random_Letters()}]
    preparedDocs = []
    docs.forEach (doc)->
      preparedDocs.push(model.deepCopy(doc))

    preparedDocs.forEach (doc)->
      doc._id = customUtils.uid(16)
      model.checkObject(doc)
      persistence.persistNewState preparedDocs, done

  it 'load log file', ->
    logEntries = path_Db.file_Contents().split('\n')
    "There are #{logEntries.size()} log entries".log()

#  before (done)->
#    done()
#
#  it 'load db', (done)->
#    db = new NeDB { filename: path_Db, autoload:true, onload: done}
#
#  it 'test NeDB', (done)->
#
#    params = {author:'____5'.add_5_Random_Letters(), quote:'123_'.add_5_Random_Letters()}
#
#    db.insert params,(err,data)->
#      done()

#  it 'test NeDB', (done)->
#    db.find {},  (err, docs)->
#      console.log err,docs.size()
#      done()

#  #it 'deleteDb', ->
#  #  log path_Db.file_Exists()
   #  path_Db.log().file_Delete()
   #  log path_Db.file_Exists()
