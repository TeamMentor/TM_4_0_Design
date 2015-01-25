(function() {
  var Config, Library_Controller, app, cheerio, expect, fs, path;

  fs = require('fs');

  path = require('path');

  cheerio = require('cheerio');

  expect = require('chai').expect;

  app = require('../../server');

  Config = require('../../Config');

  Library_Controller = require('../../controllers/Library-Controller.js');

  describe('controllers | test-Library-Controller.js |', function() {
    return describe('internal Functions.js |', function() {
      it('check ctor', function() {
        var customConfig, customVersion, custom_libraryController, libraryController, req, res;
        req = {};
        res = {};
        libraryController = new Library_Controller(req, res);
        expect(libraryController).to.be.an('Object');
        expect(libraryController.libraries).to.be.an('Object');
        expect(libraryController.req).to.deep.equal(req);
        expect(libraryController.res).to.deep.equal(res);
        expect(libraryController.config).to.deep.equal(new Config());
        expect(libraryController.jade_Service.config).to.be.an('Object');
        expect(libraryController.jade_Service.config.version).to.equal(new Config().version);
        customConfig = new Config();
        customVersion = "aa.bb.cc";
        customConfig.version = customVersion;
        custom_libraryController = new Library_Controller(req, res, customConfig);
        expect(custom_libraryController.config).to.equal(customConfig);
        expect(custom_libraryController.jade_Service.config).to.equal(customConfig);
        return expect(custom_libraryController.jade_Service.config.version).to.equal(customVersion);
      });
      it('check default libraries mappings', function() {
        var libraries;
        libraries = new Library_Controller().libraries;
        expect(libraries).to.be.an('Object');
        expect(libraries.Uno).to.be.an('Object');
        expect(libraries.Uno.id).to.be.an('String');
        expect(libraries.Uno.repo).to.be.an('String');
        expect(libraries.Uno.site).to.be.an('String');
        expect(libraries.Uno.title).to.be.an('String');
        expect(libraries.Uno.name).to.equal('Uno');
        expect(libraries.Uno.id).to.equal('be5273b1-d682-4361-99d9-6234f2d47eb7');
        expect(libraries.Uno.repo).to.equal('https://github.com/TMContent/Lib_UNO');
        expect(libraries.Uno.site).to.equal('https://tmdev01-uno.teammentor.net/');
        expect(libraries.Uno.title).to.equal('Index');
        return expect(libraries.ABC).to.not.be.an('Object');
      });
      it('mapLibraryData', function(done) {
        var libraries, library, library_Controller, library_ID, library_Key, library_Name;
        library_Controller = new Library_Controller();
        libraries = library_Controller.libraries;
        library_Key = "Uno";
        library_Name = "Guidance";
        library_ID = 'be5273b1-d682-4361-99d9-6234f2d47eb7';
        library = libraries[library_Key];
        expect(library).to.be.defined;
        libraries.Uno.data = null;
        return library_Controller.mapLibraryData(library, function() {
          var data;
          expect(library.data).to.be.not["null"];
          data = library.data;
          expect(data).to.be.an('object');
          expect(data.name).to.be.an('String');
          expect(data.libraryId).to.be.an('String');
          expect(data.guidanceItems).to.be.an('Array');
          expect(data.name).to.equal(library_Name);
          expect(data.libraryId).to.equal(library_ID);
          return library_Controller.mapLibraryData(library, function() {
            expect(library.data).to.deep.equal(data);
            return done();
          });
        });
      });
      it('mapLibraryData (using cache', function(done) {
        var cacheFile, library, libraryData, library_Controller;
        library_Controller = new Library_Controller();
        libraryData = {
          some: 'data'
        };
        library = {
          id: 'abc123',
          data: libraryData
        };
        cacheFile = library_Controller.cacheLibraryData(library);
        expect(fs.existsSync(cacheFile)).to.be["true"];
        library.data = null;
        return library_Controller.mapLibraryData(library, function() {
          fs.unlinkSync(cacheFile);
          expect(fs.existsSync(cacheFile)).to.be["false"];
          return done();
        });
      });
      it('cachedLibraryData', function() {
        var cacheFile, library, libraryData, libraryId, libraryJson, library_Controller;
        library_Controller = new Library_Controller();
        expect(library_Controller.cachedLibraryData).to.be.an('Function');
        expect(library_Controller.cachedLibraryData()).to.equal(null);
        libraryId = 'abc123';
        libraryJson = '{ "id" : "' + libraryId + '", "name" : "' + libraryId + '"}';
        library = {
          id: libraryId
        };
        cacheFile = library_Controller.cachedLibraryData_File(library);
        fs.writeFileSync(cacheFile, libraryJson);
        expect(fs.existsSync(cacheFile)).to.be["true"];
        libraryData = library_Controller.cachedLibraryData(library);
        expect(libraryData).to.be.an('Object');
        expect(libraryData.id).to.equal(libraryId);
        expect(libraryData.name).to.equal(libraryId);
        expect(libraryData.abc).to.not.equal(libraryId);
        fs.unlinkSync(cacheFile);
        return expect(fs.existsSync(cacheFile)).to.be["false"];
      });
      it('cacheLibraryData', function() {
        var cacheFile, fileContents, library, library_Controller;
        library_Controller = new Library_Controller();
        expect(library_Controller.cacheLibraryData).to.be.an('Function');
        expect(library_Controller.cacheLibraryData()).to.equal(null);
        library = {
          id: 'abc123'
        };
        cacheFile = library_Controller.cachedLibraryData_File(library);
        expect(library_Controller.cacheLibraryData(library)).to.equal(cacheFile);
        fileContents = fs.readFileSync(cacheFile, 'utf8');
        expect(fileContents).to.equal(JSON.stringify(library));
        expect(JSON.parse(fileContents)).to.deep.equal(library);
        fs.unlinkSync(cacheFile);
        return expect(fs.existsSync(cacheFile)).to.be["false"];
      });
      return it('cachedLibraryData_Path', function() {
        var expectedPath, library, libraryId, library_Controller;
        libraryId = 'abc123';
        library_Controller = new Library_Controller();
        library = {
          id: libraryId
        };
        expectedPath = path.join(library_Controller.config.library_Data, libraryId + ".json");
        expect(library_Controller.cachedLibraryData_File(null)).to.equal(null);
        return expect(library_Controller.cachedLibraryData_File(library)).to.equal(expectedPath);
      });
    });
  });

}).call(this);
