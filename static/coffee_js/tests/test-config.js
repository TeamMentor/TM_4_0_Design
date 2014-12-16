(function() {
  var Config, expect, fs;

  fs = require('fs');

  expect = require('chai').expect;

  Config = require('../Config');

  describe("test-Config.js |", function() {
    it("Ctor (w/ default values)", function() {
      var config;
      expect(Config).to.be.an('Function');
      config = new Config();
      expect(config).to.be.an('Object');
      expect(config.cache_folder).to.be.an('String');
      expect(config.jade_Compilation).to.be.an('String');
      expect(config.library_Data).to.be.an('String');
      expect(config.createCacheFolders).to.be.an('Function');
      expect(config.cache_folder).to.equal(process.cwd() + "/.tmCache");
      expect(config.jade_Compilation).to.equal(config.cache_folder + "/jade_Compilation");
      expect(config.library_Data).to.equal(config.cache_folder + "/library_Data");
      expect(config.version).to.equal('0.1.0');
      return expect(config.enable_Jade_Cache).to.equal(false);
    });
    it("Ctor (w/ custom values)", function() {
      var config, custom_cache_folder, custom_config, custom_enable_Jade_Cache;
      config = new Config();
      custom_cache_folder = '___aaaa';
      custom_enable_Jade_Cache = !config.enable_Jade_Cache;
      custom_config = new Config(custom_cache_folder, custom_enable_Jade_Cache);
      expect(custom_config.cache_folder).to.equal(process.cwd() + '/' + custom_cache_folder);
      expect(custom_config.enable_Jade_Cache).to.equal(custom_enable_Jade_Cache);
      expect(fs.existsSync(custom_config.cache_folder)).to.be["false"];
      return expect(fs.existsSync(custom_config.jade_Compilation)).to.be["false"];
    });
    return it("createCacheFolders", function() {
      var config;
      config = new Config();
      config.createCacheFolders();
      expect(fs.existsSync(config.cache_folder)).to.be["true"];
      expect(fs.existsSync(config.jade_Compilation)).to.be["true"];
      return expect(fs.existsSync(config.library_Data)).to.be["true"];
    });
  });

}).call(this);
