GoogleAnalytics_Service = require('./../../src/services/GoogleAnalytics-Service')
expect                  = require("chai").expect
assert                  = require("chai").assert
describe '| services | GoogleAnalytics-Service.test |', ->

  ga_Service = null


  before ->
    ga_Service = new GoogleAnalytics_Service()

  it 'constructor()',->
    using new GoogleAnalytics_Service(), ->
      @.setup (callback) ->
        assert.isUndefined(callback, 'callback is defined');

  it 'constructor, Google Analytics invalid code()',->
    using new GoogleAnalytics_Service(), ->
      @.config.gaTrackingId = 'aaaa'
      @.setup (callback) ->
        assert.isDefined(callback, 'callback is undefined');
        callback.assert_Is 'Error initializing Google Analytics Account ID is invalid'

  it 'constructor, Google Analytics invalid code (Must be UA- format)()',->
    using new GoogleAnalytics_Service(), ->
      @.config.gaTrackingId = 'AB-1230404-1'
      @.setup (callback) ->
        assert.isDefined(callback, 'callback is undefined');
        callback.assert_Is 'Error initializing Google Analytics Account ID is invalid'

  it 'constructor, Google Analytics invalid code (Must be have numbers)()',->
    using new GoogleAnalytics_Service(), ->
      @.config.gaTrackingId = 'AB-AAA'
      @.setup (callback) ->
        assert.isDefined(callback, 'callback is undefined');
        callback.assert_Is 'Error initializing Google Analytics Account ID is invalid'

  it 'constructor, Google Analytics null code()',->
    using new GoogleAnalytics_Service(), ->
      @.config.gaTrackingId = ''
      @.setup (callback) ->
        assert.isDefined(callback, 'callback is not defined');
        callback.assert_Is 'Error initializing Google Analytics Account ID is invalid'

  it 'constructor, Google Analytics require a domain ()',->
    using new GoogleAnalytics_Service(), ->
      @.config.gaTrackingId    = 'UA-1234455'
      @.config.gaTrackingSite  = ''
      @.setup (callback) ->
        assert.isDefined(callback, 'callback is  not defined');
        callback.assert_Is 'Error initializing Google Analytics Domain is invalid'

  it 'constructor, Google Analytics should accept an account ID without profile number()',->
    using new GoogleAnalytics_Service(), ->
      @.config.gaTrackingId = 'UA-123'
      @.setup (callback) ->
        assert.isUndefined(callback, 'callback is defined');

  it 'constructor,Config values are retrieved successfully()',->
    using new GoogleAnalytics_Service(), ->
      @.setup (callback)->
        assert.isUndefined(callback, 'callback is defined');

  it 'Tracking Page ,Page tracked successfully()',->
    using new GoogleAnalytics_Service(), ->
      @.trackPage('a','b')



