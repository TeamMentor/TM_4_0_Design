loggly     = null
winston    = null
Logentries = null

class Logging_Service

  dependencies: ()->
    loggly     = require 'loggly'
    winston    = require 'winston'
    Logentries = require 'winston-logentries'

  constructor: (options)->
    @.dependencies()
    @.options          = options || {}
    @.log_Folder       = @options.log_Folder || './.logs'
    @.log_File         = null
    @.token_LogEntries = 'f888b272-e834-4132-bec2-4d4eb953319a'
    @.logger           = null
    @.original_Console = null

  setup: =>
    @.log_File = @.log_Folder.folder_Create().path_Combine('tm-design')

    @.logger = new (winston.Logger)

    @.logger .add(   winston.transports.DailyRotateFile, {filename: @.log_File, datePattern: '.yyyy-MM-dd_HH'})
             .add(   winston.transports.Logentries     , { token: @.token_LogEntries })
             .add(   winston.transports.Console        , { timestamp: true, level: 'verbose', colorize: true });

    #hook console
    @.original_Console = console.log
    console.log        = @.info

    log '[Logging-Service] console hooked'

    global.logger = @

    @



  info: (data)=>
    @.logger.info data

  log: (data)=>
    @.logger.info data

  error: (data)=>
    @.logger.error data


  test_Loggy: ()->
    options =

      token: "f1f980bd-342e-412b-ad4d-30d785579baf",
      subdomain: "teammentor",
      tags: ["NodeJS"],
      json:true

    client = loggly.createClient(options)
    client.log("Hello World from Node.js!");

module.exports = Logging_Service