fs     = require 'fs'
path   = require 'path'
expect = require('chai').expect
Config = require('../../src/misc/Config')

expectedTm_35_Server  ='https://tmdev01-uno.teammentor.net/'
expectedTmWebServices = 'Aspx_Pages/TM_WebServices.asmx'


describe '| misc | Config', ()->

  before ->

  after ->

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

    it 'createCacheFolders', ->
        config = new Config()
        config.createCacheFolders()
        expect(fs.existsSync(config.cache_folder    )).to.be.true
        expect(fs.existsSync(config.jade_Compilation)).to.be.true
        expect(fs.existsSync(config.library_Data    )).to.be.true

  describe '| with custom SiteData location',->

    siteData_Folder = '_tmp_SiteData'
    siteData_Name   = 'SiteData_Temp'
    tmConfig        =
      tm_Design:
        port: 12345
      tm_Graph:
        port: 23456

    before ->
      siteData_Folder = siteData_Folder             .folder_Create()                .assert_Folder_Exists()
      siteData_Folder.path_Combine(siteData_Name   ).folder_Create()                .assert_Folder_Exists()
                     .path_Combine('TM_4'          ).folder_Create()                .assert_Folder_Exists()
                     .path_Combine('tm.config.json').file_Write(tmConfig.json_Str()).assert_File_Exists()

    after ->
      siteData_Folder.folder_Delete_Recursive()
                     .assert_True()

    it 'When process.env.TM_SITE_DATA is not set', ->
      using new Config(), ->
        assert_Is_Undefined @.siteData_Folder()
        assert_Is_Undefined @.siteData_TM_Config()

    it 'siteData_Folder (when process.env.TM_SITE_DATA is set to a full path)', ->
      using new Config(), ->
        process.env[@.DEFAULT_ENV_TM_SITE_DATA] = siteData_Folder
        @.siteData_Folder().assert_Is siteData_Folder

    it '@.siteData_Folder (when process.env.TM_SITE_DATA is set to a virtual path)', ->
      using new Config(), ->
        virtual_Path = "#{siteData_Folder.folder_Name()}/#{siteData_Name}"
        process.env[@.DEFAULT_ENV_TM_SITE_DATA] = virtual_Path
        @.siteData_Folder().assert_Contains virtual_Path
        virtual_Path.folder_Create()
        @.siteData_Folder().assert_Folder_Exists()

    it 'siteData_TM_Config, load_Options, options (when siteData_Folder is valid)', ->
      using new Config(), ->
        virtual_Path = "#{siteData_Folder.folder_Name()}/#{siteData_Name}"
        process.env[@.DEFAULT_ENV_TM_SITE_DATA] = virtual_Path

        @.siteData_TM_Config().assert_File_Exists()
        options = @.load_Options().assert_Is @._options
                                  .assert_Is @.options()
        options.tm_Design.port.assert_Is 12345
        options.tm_Graph.port.assert_Is 23456

