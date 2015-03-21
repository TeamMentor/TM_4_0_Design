winston    = null

class Logging_Service

  dependencies: ()->
    winston    = require 'winston'

  constructor: (options)->
    @.dependencies()
    @.options          = options || {}
    @.log_Folder       = @options.log_Folder || './.logs'
    @.log_File         = null
    @.logger           = null
    @.original_Console = null

  setup: =>
    @.log_File = @.log_Folder.folder_Create().path_Combine('tm-design')

    @.logger = new (winston.Logger)

    @.logger .add(   winston.transports.DailyRotateFile, {filename: @.log_File, datePattern: '.yyyy-MM-dd'})
             .add(   winston.transports.Console        , { timestamp: true, level: 'verbose', colorize: true });

    @.hook_Console()
    @

  hook_Console: =>
    @.original_Console = console.log
    console.log        = (args...)=> @.info args...
    global.logger      = @
    log '[Logging-Service] console hooked'

  restore_Console: =>
    console.log = @.original_Console
    log 'Console restored'

  info: (data)=>
    @.logger.info data

  log: (data)=>
    @.logger.info data

  error: (data)=>
    @.logger.error data


module.exports = Logging_Service