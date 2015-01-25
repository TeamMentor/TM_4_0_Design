(function() {
  var GitHub_Service, GraphService, fs;

  require('fluentnode');

  fs = require('fs');

  GitHub_Service = require('./GitHub-Service');

  GraphService = (function() {
    function GraphService() {
      this.dataFile = './src/article-data.json';
      this.data = null;
    }

    GraphService.prototype.dataFromGitHub = function(callback) {
      var path, repo, user;
      user = "TMContent";
      repo = "TM_Test_GraphData";
      path = 'GraphData/article_Data.json';
      return new GitHub_Service().file(user, repo, path, function(data) {
        return callback(JSON.parse(data));
      });
    };

    GraphService.prototype.graphDataFromGraphDB = function(dataId, queryId, filters, callback) {
      var graphDataUrl, server;
      server = 'http://localhost:1332';
      dataId = dataId || 'tm-uno';
      graphDataUrl = "" + server + "/data/" + dataId + "/query/filter/tm-search?show=" + queryId;
      if (filters) {
        graphDataUrl += "&filters=" + filters;
      }
      console.log("****:   " + graphDataUrl);
      return require('request').get(graphDataUrl, function(err, response, body) {
        if (err) {
          throw err;
        }
        return callback(JSON.parse(body));
      });
    };

    return GraphService;

  })();

  module.exports = GraphService;

}).call(this);
