(function() {
  var GitHub_Service, expect;

  require('fluentnode');

  GitHub_Service = require('./../../services/GitHub-Service');

  expect = require('chai').expect;

  describe('services | test-GitHub-Service |', function() {
    var gitHubService;
    gitHubService = new GitHub_Service();
    this.timeout(3500);
    it('test constructor', function() {
      expect(GitHub_Service).to.be.an('Function');
      gitHubService = new GitHub_Service();
      expect(gitHubService).to.be.an('Object');
      expect(gitHubService.key).to.be.an('String');
      expect(gitHubService.secret).to.be.an('String');
      expect(gitHubService.version).to.be.an('String');
      expect(gitHubService.debug).to.be.an('boolean');
      return expect(gitHubService.github).to.be.an('object');
    });
    it('authenticate', function() {
      expect(gitHubService.authenticate).to.be.an('Function');
      expect(gitHubService.authenticate()).to.equal(gitHubService);
      expect(gitHubService.github).to.not.equal(null);
      expect(gitHubService.github.auth).to.be.an('Object');
      expect(gitHubService.github.auth.type).to.equal('oauth');
      expect(gitHubService.github.auth.key).to.equal(gitHubService.key);
      return expect(gitHubService.github.auth.secret).to.equal(gitHubService.secret);
    });
    it('rateLimit', function(done) {
      expect(gitHubService.rateLimit).to.be.an('Function');
      return gitHubService.rateLimit(function(data) {
        expect(data).to.be.an('Object');
        expect(data.resources).to.be.an('Object');
        expect(data.resources.core).to.be.an('Object');
        expect(data.resources.core.limit).to.be.an('number');
        console.log("\n remaining : " + data.resources.core.remaining);
        console.log(" next reset: " + new Date(data.resources.core.reset * 1000).toLocaleTimeString());
        return done();
      });
    });
    it('gist_Raw', function(done) {
      var gistId;
      expect(gitHubService.gist_Raw).to.be.an('Function');
      gistId = "ad328585205f67569e0d";
      return gitHubService.gist_Raw(gistId, function(data) {
        var files;
        expect(data).to.be.an('Object');
        files = Object.keys(data.files);
        expect(files).to.be.an("Array");
        expect(files).to.contain('Search_Data_Validation.json');
        expect(files).to.contain('Search_Input_Validation.json');
        return done();
      });
    });
    it('gist', function(done) {
      var file, gistId;
      expect(gitHubService.gist).to.be.an('Function');
      gistId = "ad328585205f67569e0d";
      file = 'Search_Data_Validation.json';
      return gitHubService.gist(gistId, file, function(data) {
        var searchData;
        expect(data).to.be.an('String');
        searchData = JSON.parse(data);
        expect(searchData).to.be.an('Object');
        expect(searchData.title).to.equal('Data Validation');
        return done();
      });
    });
    it('repo_Raw', function(done) {
      var repo, user;
      expect(gitHubService.repo_Raw).to.be.an('Function');
      user = "TMContent";
      repo = "TM_Test_GraphData";
      return gitHubService.repo_Raw(user, repo, function(data) {
        expect(data).to.be.an('Object');
        return done();
      });
    });
    it('tree_Raw', function(done) {
      var repo, sha, user;
      expect(gitHubService.tree_Raw).to.be.an('Function');
      user = "TMContent";
      repo = "TM_Test_GraphData";
      sha = 'master';
      return gitHubService.tree_Raw(user, repo, sha, function(data) {
        var files, item;
        files = (function() {
          var _i, _len, _ref, _results;
          _ref = data.tree;
          _results = [];
          for (_i = 0, _len = _ref.length; _i < _len; _i++) {
            item = _ref[_i];
            _results.push(item.path);
          }
          return _results;
        })();
        expect(data).to.be.an('Object');
        return done();
      });
    });
    return it('file', function(done) {
      var repo, sha, user;
      expect(gitHubService.file).to.be.an('Function');
      user = "TMContent";
      repo = "TM_Test_GraphData";
      sha = 'SearchData/Data_Validation.json';
      return gitHubService.file(user, repo, sha, function(data) {
        var searchData;
        expect(data).to.be.an('String');
        searchData = JSON.parse(data);
        expect(searchData).to.be.an('Object');
        expect(searchData.title).to.equal('Data Validation');
        return done();
      });
    });
  });

}).call(this);
