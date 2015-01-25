Config = require('../../misc/Config')
fs   = require 'fs'
expectedTm_35_Server  ='https://tmdev01-uno.teammentor.net/'
expectedTmWebServices = 'Aspx_Pages/TM_WebServices.asmx'


describe 'services | Config.test', ()->
  it 'Constructor', ->
    using new Config(), ->
      @.cache_folder.assert_Contains ('tmCache')
      @.jade_Compilation.assert_Contains('.tmCache/jade_Compilation')
      @.tmWebServices.assert_Is(expectedTmWebServices)
      @.tm_35_Server.assert_Is(expectedTm_35_Server)
      @.version.assert_Is('0.1.1')
      @.library_Data.assert_Contains('library_Data')



