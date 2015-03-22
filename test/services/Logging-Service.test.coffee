Logging_Service = require('./../../src/services/Logging-Service')

describe '| services | Logging-Service.test |', ->

  logging_Service = null

  before ->
    logging_Service = new Logging_Service().setup()

  after ()->
    logging_Service.assert_Is_Object()
    logging_Service.original_Console.assert_Is_Function()
    logging_Service.restore_Console()
    console.log       .assert_Is_Not global.info
    console.log       .assert_Is logging_Service.original_Console

  it 'constructor()',->
    using new Logging_Service(), ->
      @.options         .assert_Is {}
      @.log_Folder      .assert_Is './.logs'
      assert_Is_Null @.logger

  it 'setup',->
      logging_Service.assert_Is_Instance_Of Logging_Service
      logger.assert_Is logging_Service

  it 'info', ()->
    logging_Service.info '[Logging-Service.test] Testing info'

  it 'error', ()->
    logging_Service.error '[Logging-Service.test] Testing error'

  it 'console.log', ()->
    console.log { done : 'using console.log : '.add_5_Letters()}

  it 'log', ()->
    console.log { done : 'using log : '.add_5_Letters()}


