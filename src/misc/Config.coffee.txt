path = require 'path'
fs   = require 'fs'

class Config

  constructor: (options)->   #(cache_folder, enable_Jade_Cache) ->

    @.DEFAULT_RELATIVE_PATH_TO_CONFIG_FOLDER = '../../../../config'
    @.DEFAULT_TM_CONFIG_FILENAME             = 'TM_4/tm.config.json'
    @.DEFAULT_ENV_TM_SITE_DATA               = 'TM_SITE_DATA'

    @._options = options || {}

    @tm_35_Server          ='https://tmdev01-uno.teammentor.net/'
    @tmWebServices         ='Aspx_Pages/TM_WebServices.asmx'

    @analitycsTrackUrl     =''                                            # Piwik Analytics Url
    @analitycsSiteId       =''                                            # Site Id
    @analitycsEnabled      = false                                        # Whether or not tracking information is enabled.
    @analitycsTrackingSite =''                                            # Tracking site base URL.

  cache_Folder: ()=>
    path.join(process.cwd(), @.options.cache_folder || ".tmCache").log()


  jade_Compilation: ()=>
    path.join(@.cache_Folder(), "jade_Compilation")


  jade_Cache: ()=>
    return @.options?.enable_Jade_Cache || false

  createCacheFolders : ()=>
    if not fs.existsSync @.cache_Folder()
      fs.mkdirSync @.cache_Folder()
    if not fs.existsSync @.jade_Compilation()
      fs.mkdirSync @.jade_Compilation()

  options: ()=>
    @._options

  load_Options: ()=>
    tmConfig_File = @.siteData_TM_Config()?.real_Path()
    if tmConfig_File?.file_Exists()                                      # if @.siteData_TM_Config exists
      tmConfig = tmConfig_File.load_Json()                              # load as json
      if (tmConfig)                                                     # if data was loaded ok
        @._options = tmConfig                                            # set @.options with loaded object
    @.options()

  siteData_Folder: ()=>
    if process.env[@.DEFAULT_ENV_TM_SITE_DATA]
      if process.env[@.DEFAULT_ENV_TM_SITE_DATA].folder_Exists()        # if the value provided in process.env[@.DEFAULT_ENV_TM_SITE_DATA] is full path to an existing folder
        return process.env[@.DEFAULT_ENV_TM_SITE_DATA]                  #   use its value
      __dirname.path_Combine(@.DEFAULT_RELATIVE_PATH_TO_CONFIG_FOLDER)  # else use it has part of a path created
               .path_Combine process.env[@.DEFAULT_ENV_TM_SITE_DATA]    #    with @.DEFAULT_RELATIVE_PATH_TO_CONFIG_FOLDER

  siteData_TM_Config: ()=>
      @.siteData_Folder()?.path_Combine @.DEFAULT_TM_CONFIG_FILENAME


module.exports = Config
