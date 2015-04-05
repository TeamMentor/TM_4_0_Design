fs     = require 'fs'
path   = require 'path'
expect = require('chai').expect
Config = require('../../src/misc/Config')

expectedTm_35_Server  ='https://tmdev01-uno.teammentor.net/'
expectedTmWebServices = 'Aspx_Pages/TM_WebServices.asmx'


describe '| misc | Config.test', ()->
  it 'constructor', ->
    using new Config(), ->
      @.cache_folder.assert_Contains ('tmCache')
      @.jade_Compilation.assert_Contains(".tmCache#{path.sep}jade_Compilation")
      @.tmWebServices.assert_Is(expectedTmWebServices)
      @.tm_35_Server.assert_Is(expectedTm_35_Server)
      @.version.assert_Is('0.1.1')
      @.library_Data.assert_Contains('library_Data')

  it "Ctor (w/ default values)", ->
        expect(Config                  ).to.be.an('Function')

        config = new Config()

        expect(config                   ).to.be.an('Object'  )
        expect(config.cache_folder      ).to.be.an('String'  )
        expect(config.jade_Compilation  ).to.be.an('String'  )
        expect(config.library_Data      ).to.be.an('String'  )
        expect(config.createCacheFolders).to.be.an('Function')

        expect(config.cache_folder     ).to.equal(process.cwd()        + "#{path.sep}.tmCache")
        expect(config.jade_Compilation ).to.equal(config.cache_folder  + "#{path.sep}jade_Compilation")
        expect(config.library_Data     ).to.equal(config.cache_folder  + "#{path.sep}library_Data")

        expect(config.version          ).to.equal('0.1.1' )
        expect(config.enable_Jade_Cache).to.equal(false   )

    it "Ctor (w/ custom values)", ->
        config = new Config()

        custom_cache_folder      = '___aaaa'
        custom_enable_Jade_Cache = not config.enable_Jade_Cache
        custom_config            = new Config(custom_cache_folder, custom_enable_Jade_Cache)

        expect(custom_config.cache_folder     ).to.equal(process.cwd() + path.sep + custom_cache_folder)
        expect(custom_config.enable_Jade_Cache).to.equal(custom_enable_Jade_Cache)
        expect(fs.existsSync(custom_config.cache_folder    )).to.be.false
        expect(fs.existsSync(custom_config.jade_Compilation)).to.be.false

    it "createCacheFolders", ->
        config = new Config()
        config.createCacheFolders()
        expect(fs.existsSync(config.cache_folder    )).to.be.true
        expect(fs.existsSync(config.jade_Compilation)).to.be.true
        expect(fs.existsSync(config.library_Data)).to.be.true
