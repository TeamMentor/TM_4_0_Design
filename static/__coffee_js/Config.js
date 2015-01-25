(function() {
  var Config, fs, path;

  path = require('path');

  fs = require('fs');

  Config = (function() {
    function Config(cache_folder, enable_Jade_Cache) {
      this.cache_folder = path.join(process.cwd(), cache_folder || ".tmCache");
      this.jade_Compilation = path.join(this.cache_folder, "jade_Compilation");
      this.library_Data = path.join(this.cache_folder, "library_Data");
      this.version = '0.1.1';
      this.enable_Jade_Cache = enable_Jade_Cache || false;
      this.disableAuth = false;
    }

    Config.prototype.createCacheFolders = function() {
      if (!fs.existsSync(this.cache_folder)) {
        fs.mkdirSync(this.cache_folder);
      }
      if (!fs.existsSync(this.jade_Compilation)) {
        fs.mkdirSync(this.jade_Compilation);
      }
      if (!fs.existsSync(this.library_Data)) {
        return fs.mkdirSync(this.library_Data);
      }
    };

    return Config;

  })();

  module.exports = Config;

}).call(this);
