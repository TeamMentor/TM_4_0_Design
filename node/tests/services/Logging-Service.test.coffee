Logging_Service = require('./../../services/Logging-Service')

describe '| services | Logging-Service.test |', ->

  logging_Service = null

  before ->
    logging_Service = new Logging_Service().setup()

  after (done)->
    100.wait done

  it 'constructor()',->
    using new Logging_Service(), ->
      @.options         .assert_Is {}
      @.log_Folder      .assert_Is './.logs'
      @.token_LogEntries.assert_Contains '-'
      assert_Is_Null @.logger
      #assert_Is_Null @.winston

  it 'setup',->
    using new Logging_Service().setup(), ->
      @.assert_Is_Instance_Of Logging_Service
      logger.assert_Is @
      #@.logger.transports.DailyRotateFile.assert_Is_Function()
      #@.logger.transports.Logentries.assert_Is_Function()

  it 'info', ()->
    logging_Service.info '[Logging-Service.test] Testing info'

  it 'error', ()->
    logging_Service.error '[Logging-Service.test] Testing error'

  it 'console.log', ()->
    console.log { done : 'using console.log : '.add_5_Letters()}

  it 'log', ()->
    console.log { done : 'using log : '.add_5_Letters()}


