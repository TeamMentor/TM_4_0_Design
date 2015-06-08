path = require 'path'
fs   = require 'fs'

class Config
  constructor: (cache_folder, enable_Jade_Cache) ->
    @cache_folder          = path.join(process.cwd(), cache_folder || ".tmCache")
    @jade_Compilation      = path.join(@cache_folder, "jade_Compilation")
    @library_Data          = path.join(@cache_folder, "library_Data")
    @version               = '0.1.1'
    @enable_Jade_Cache     = enable_Jade_Cache || false
    @tm_35_Server          ='https://tmdev01-uno.teammentor.net/'
    @tmWebServices         ='Aspx_Pages/TM_WebServices.asmx'

    @analitycsTrackUrl     =''                                            # Piwik Analytics Url
    @analitycsSiteId       =''                                            # Site Id
    @analitycsEnabled      = false                                        # Whether or not tracking information is enabled.
    @analitycsTrackingSite =''                                            # Tracking site base URL.

  createCacheFolders : ()->
    if not fs.existsSync(@cache_folder)
      fs.mkdirSync(@cache_folder)
    if not fs.existsSync(@jade_Compilation)
      fs.mkdirSync(@jade_Compilation)
    if not fs.existsSync(@library_Data)
      fs.mkdirSync(@library_Data)

  has_SiteData_Config: ()->
    false

module.exports = Config
