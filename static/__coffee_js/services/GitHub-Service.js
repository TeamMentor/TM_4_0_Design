(function() {
  var GitHubApi, GitHubService,
    __indexOf = [].indexOf || function(item) { for (var i = 0, l = this.length; i < l; i++) { if (i in this && this[i] === item) return i; } return -1; };

  GitHubApi = require('github');

  GitHubService = (function() {
    function GitHubService() {
      this.key = "c2012dff24635c968afc";
      this.secret = "8e00a142cfc1ad59a22a4511c082476583cfb3da";
      this.version = "3.0.0";
      this.debug = false;
      this.github = null;
      this.authenticate();
    }

    GitHubService.prototype.authenticate = function() {
      this.github = new GitHubApi({
        version: this.version,
        debug: this.debug
      });
      this.github.authenticate({
        type: "oauth",
        key: this.key,
        secret: this.secret
      });
      return this;
    };

    GitHubService.prototype.rateLimit = function(callback) {
      return this.github.misc.rateLimit({}, function(err, res) {
        if (err) {
          throw err;
        }
        return callback(res);
      });
    };

    GitHubService.prototype.gist_Raw = function(id, callback) {
      return this.github.gists.get({
        id: id
      }, function(err, res) {
        if (err) {
          throw err;
        }
        return callback(res);
      });
    };

    GitHubService.prototype.gist = function(id, file, callback) {
      return this.github.gists.get({
        id: id
      }, function(err, res) {
        if (err) {
          throw err;
        }
        if ((__indexOf.call(Object.keys(res.files), file) >= 0)) {
          return callback(res.files[file].content);
        } else {
          return callback(null);
        }
      });
    };

    GitHubService.prototype.repo_Raw = function(user, repo, callback) {
      return this.github.repos.get({
        user: user,
        repo: repo
      }, function(err, res) {
        if (err) {
          throw err;
        }
        return callback(res);
      });
    };

    GitHubService.prototype.tree_Raw = function(user, repo, sha, callback) {
      var recursive;
      recursive = true;
      return this.github.gitdata.getTree({
        user: user,
        repo: repo,
        sha: sha,
        recursive: recursive
      }, function(err, res) {
        if (err) {
          throw err;
        }
        return callback(res);
      });
    };

    GitHubService.prototype.file = function(user, repo, path, callback) {
      var recursive;
      recursive = true;
      return this.github.repos.getContent({
        user: user,
        repo: repo,
        path: path
      }, function(err, res) {
        var asciiContent;
        if (err) {
          throw err;
        }
        asciiContent = new Buffer(res.content, 'base64').toString('ascii');
        return callback(asciiContent);
      });
    };

    return GitHubService;

  })();

  module.exports = GitHubService;

}).call(this);
