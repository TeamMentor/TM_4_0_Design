path = require 'path'
fs   = require 'fs'

class Config
    constructor: (cache_folder, enable_Jade_Cache) ->
        @cache_folder      = path.join(process.cwd(), cache_folder || ".tmCache")
        @jade_Compilation  = path.join(@cache_folder, "jade_Compilation")
        @library_Data      = path.join(@cache_folder, "library_Data")
        @version           = '0.1.0'
        @enable_Jade_Cache = enable_Jade_Cache || false
        @disableAuth       = false
        
    createCacheFolders : ()->
        if not fs.existsSync(@cache_folder)
            fs.mkdirSync(@cache_folder)
        if not fs.existsSync(@jade_Compilation)
            fs.mkdirSync(@jade_Compilation)
        if not fs.existsSync(@library_Data)
            fs.mkdirSync(@library_Data)
    
module.exports = Config
