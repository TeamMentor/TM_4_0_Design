piwikAnalytics   = null
piwik            = null

class Analytics_Service

  dependencies:()->
    piwikAnalytics = require 'piwik-tracker'

  constructor:(req, res)->
    @.dependencies()
    @.req               = req
    @.res               = res
    @.analitycsEnabled  = global.config?.analitycsEnabled
    @.analitycsSiteId   = global.config?.analitycsSiteId
    @.analitycsTrackUrl = global.config?.analitycsTrackUrl

  setup:() =>
    if @.analitycsEnabled
      'Analytics is enabled'.log()
      if not @.analitycsSiteId
        'Error: siteId must be provided.'.log()
      else if not @.analitycsTrackUrl
        'Error: A tracker URL must be provided, e.g. http://example.com/piwik.php'.log()
      else
        piwik = new piwikAnalytics(@.analitycsSiteId, @.analitycsTrackUrl)
    else
      'Analytics not enabled'.log()

  remoteIp: () ->
    ipAddr = @.req.headers["x-forwarded-for"]
    if (ipAddr)
      ipAddr = @.req.headers['x-forwarded-for'].split(',')[0]
    else
      ipAddr = @.req.connection.remoteAddress
    return ipAddr

  apiKey:() ->
    if (process.cwd().path_Combine('../Site_Data/secrets.json').file_Exists())
      secrets = process.cwd().path_Combine('../Site_Data/secrets.json').load_Json()
      return secrets.AnalyticsApiKey
    else
      return ''

  trackUrl: (url) ->
    piwik?.track (url)

  track : (pageTitle,eventCategory, eventName) ->
    if not @.analitycsEnabled
      return

    actionName = if pageTitle then pageTitle else @.req.url
    url        = @.analitycsTrackingSite + @.req.url
    ipAddress  = @.remoteIp()

    piwik?.track({
      url            :url,
      action_name    :actionName,
      _id            :@.req.sessionID,
      rand           :''.add_5_Random_Letters(),                          #random value to avoid caching
      apiv           :1,                                                  #Api version always set to 1
      ua             :@.req.header?("User-Agent"),
      lang           :@.req.header?("Accept-Language"),
      token_auth     :@.apiKey(),
      cip            :ipAddress,
      e_c            :eventCategory,                                     #Event category
      e_a            :@.req.url,                                         #Event action
      e_n            :eventName?,                                        #Event name
      e_v            :1,                                                 #Event value
      cvar: JSON.stringify({                                             #Extra variableS
        '1': ['API version', 'v1'],
        '2': ['HTTP method', @.req.method]
      })

    });

  module.exports =Analytics_Service

