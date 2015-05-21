nodeAnalytics    = null
gaCode           = null
gaSite           = null
Config           = null

class GoogleAnalytics_Service

  dependencies:()->
    nodeAnalytics = require 'nodealytics'
    Config        = require('../misc/Config')

  setup:(callback) =>
    nodeAnalytics.initialize @.config.gaTrackingId,@.config.gaTrackingSite,(err,res) =>
      if (err?)
        callback "Error initializing Google Analytics #{err.message}"
      else
        callback undefined
      return callback

  constructor:(req, res)->
    @.dependencies()
    @.req      = req
    @.res      = res
    @.config   = new Config()
    @.setup (callback) =>
      if (callback)
        console.log (callback)


  trackPage:(pageTitle, url) ->
    nodeAnalytics.trackPage pageTitle,url,(err,res)->
      if(err? and res?.statusCode? != 200)
        return "Error tracking Page on Google Analytics #{err.message}"


  trackEvent: (eventCategory,eventAction,eventLabel,eventValue) ->
    nodeAnalytics.trackEvent eventCategory, eventAction,eventLabel,eventValue, (err,res) ->
      if(err? and res?.statusCode? != 200)
        return "Error tracking Event on Google Analytics #{err.message}"

  module.exports =GoogleAnalytics_Service

