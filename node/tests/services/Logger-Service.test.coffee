Logger_Service = require('./../../services/Logger-Service')

describe '| services | Logger-Service.test |', ->

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