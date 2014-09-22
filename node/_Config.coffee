path = require 'path'

class Config
    @cache_folder      : path.join(process.cwd(), "cacheFolder")
    @jade_Compilation  : path.join(@cache_folder, "jade_Compilation")
    @version           : '0.1.0'
    @enable_Jade_Cache: false
    
module.exports = new Config()
