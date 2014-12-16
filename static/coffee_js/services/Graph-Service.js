(function() {
  var GitHub_Service, GraphService, fs, levelgraph, levelup,
    __bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; };

  require('fluentnode');

  fs = require('fs');

  levelup = require("level");

  levelgraph = require('levelgraph');

  GitHub_Service = require('./GitHub-Service');

  GraphService = (function() {
    function GraphService() {
      this.loadTestData = __bind(this.loadTestData, this);
      this.dbPath = './.tmCache/db';
      this.level = null;
      this.db = null;
      this.dataFile = './src/article-data.json';
      this.data = null;
    }

    GraphService.prototype.closeDb = function(callback) {
      if (this.level === null) {
        return callback();
      } else {
        return this.level.close((function(_this) {
          return function() {
            return _this.db.close(function() {
              _this.db = null;
              _this.level = null;
              return callback();
            });
          };
        })(this));
      }
    };

    GraphService.prototype.openDb = function() {
      this.level = levelup(this.dbPath);
      return this.db = levelgraph(this.level);
    };

    GraphService.prototype.deleteDb = function() {
      console.log('Deleting the articleDB');
      return require('child_process').spawn('rm', ['-Rv', this.dbPath]);
    };

    GraphService.prototype.dataFromGitHub = function(callback) {
      var path, repo, user;
      user = "TMContent";
      repo = "TM_Test_GraphData";
      path = 'GraphData/article_Data.json';
      return new GitHub_Service().file(user, repo, path, function(data) {
        return callback(JSON.parse(data));
      });
    };

    GraphService.prototype.loadTestData = function(callback) {
      if (this.db === null) {
        this.openDb();
      }
      return this.dataFromGitHub((function(_this) {
        return function(data) {
          _this.data = data;
          return _this.db.put(_this.data, callback);
        };
      })(this));
    };

    GraphService.prototype.allData = function(callback) {
      return this.db.search([
        {
          subject: this.db.v("subject"),
          predicate: this.db.v("predicate"),
          object: this.db.v("object")
        }
      ], callback);
    };

    GraphService.prototype.query = function(key, value, callback) {
      switch (key) {
        case "subject":
          return this.db.get({
            subject: value
          }, callback);
        case "predicate":
          return this.db.get({
            predicate: value
          }, callback);
        case "object":
          return this.db.get({
            object: value
          }, callback);
        default:
          return callback(null, []);
      }
    };

    GraphService.prototype.createSearchData = function(folderName, callback) {
      var mapArticles, mapMetadata, mapResults, mapViews, metadata, searchData, setDefaultValues;
      searchData = {};
      setDefaultValues = function() {
        searchData.title = folderName;
        searchData.containers = [];
        searchData.resultsTitle = "n/n results showing";
        searchData.results = [];
        return searchData.filters = [];
      };
      metadata = {};
      mapMetadata = (function(_this) {
        return function() {
          var filter, item, mapping, result;
          for (item in metadata) {
            if (!(typeof metadata[item] !== 'function')) {
              continue;
            }
            filter = {};
            filter.title = item;
            filter.results = [];
            for (mapping in metadata[item]) {
              if (typeof metadata[item][mapping] !== 'function') {
                result = {
                  title: mapping,
                  size: metadata[item][mapping]
                };
                filter.results.push(result);
              }
            }
            searchData.filters.push(filter);
          }
          return callback(searchData);
        };
      })(this);
      mapArticles = (function(_this) {
        return function(articles) {
          var article;
          if (articles.empty()) {
            return mapMetadata();
          } else {
            article = articles.pop();
            return _this.query('subject', article, function(err, data) {
              var item, result, _i, _len;
              result = {
                title: null,
                link: null,
                id: null,
                summary: null,
                score: null
              };
              for (_i = 0, _len = data.length; _i < _len; _i++) {
                item = data[_i];
                switch (item.predicate) {
                  case 'Guid':
                    result.id = item.object;
                    break;
                  case 'Title':
                    result.title = item.object;
                    break;
                  case 'Summary':
                    result.summary = item.object;
                    break;
                  default:
                    if (!metadata[item.predicate]) {
                      metadata[item.predicate] = {};
                    }
                    if (metadata[item.predicate][item.object]) {
                      metadata[item.predicate][item.object]++;
                    } else {
                      metadata[item.predicate][item.object] = 1;
                    }
                }
              }
              result.link = 'https://tmdev01-uno.teammentor.net/' + result.id;
              result.score = 0;
              searchData.results.push(result);
              return mapArticles(articles);
            });
          }
        };
      })(this);
      mapViews = (function(_this) {
        return function(viewsToMap, articles) {
          var viewToMap;
          if (viewsToMap.empty()) {
            return mapArticles(articles);
          } else {
            viewToMap = viewsToMap.pop();
            return _this.query('subject', viewToMap.id, function(err, data) {
              var container, item, _i, _len;
              container = {
                title: null,
                id: null,
                size: viewToMap.size
              };
              for (_i = 0, _len = data.length; _i < _len; _i++) {
                item = data[_i];
                switch (item.predicate) {
                  case 'Guid':
                    container.id = item.object;
                    break;
                  case 'Title':
                    container.title = item.object;
                }
              }
              searchData.containers.push(container);
              return mapViews(viewsToMap, articles);
            });
          }
        };
      })(this);
      mapResults = (function(_this) {
        return function(err, data) {
          var articles, item, key, viewsCount, viewsToMap, _i, _len;
          viewsCount = {};
          articles = [];
          for (_i = 0, _len = data.length; _i < _len; _i++) {
            item = data[_i];
            articles.push(item.article);
            if (viewsCount[item.view]) {
              viewsCount[item.view]++;
            } else {
              viewsCount[item.view] = 1;
            }
          }
          searchData.resultsTitle = "" + articles.length + "/" + data.length + " results showing";
          viewsToMap = (function() {
            var _results;
            _results = [];
            for (key in viewsCount) {
              if (typeof viewsCount[key] !== 'function') {
                _results.push({
                  id: key,
                  size: viewsCount[key]
                });
              }
            }
            return _results;
          })();
          return mapViews(viewsToMap, articles);
        };
      })(this);
      setDefaultValues();
      return this.db.nav("Data Validation").archIn('Title').as('folder').archOut('Contains').as('view').archIn('View').as('article').solutions(mapResults);
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

    GraphService.prototype.graphDataFromQAServer = function(dataId, callback) {
      var graphDataUrl;
      graphDataUrl = 'http://localhost:1332/data/' + dataId + '/tm-search';
      console.log("****:   " + graphDataUrl);
      return require('request').get(graphDataUrl, function(err, response, body) {
        if (err) {
          throw err;
        }
        return callback(JSON.parse(body));
      });
    };

    GraphService.prototype.createSearchDataFromGraphData = function(graphData, filter_container, filter_query, callback) {
      var article_Ids, mapArticles, mapContainers, mapMetadata, maxArticles, metadata, searchData, setDefaultValues;
      searchData = {};
      setDefaultValues = function() {
        searchData.title = '';
        searchData.containers = [];
        searchData.resultsTitle = "";
        searchData.results = [];
        searchData.filters = [];
        searchData.filter_container = filter_container ? filter_container : '';
        return searchData.filter_query = filter_query ? filter_query : '';
      };
      metadata = {};
      setDefaultValues();
      article_Ids = graphData.nodes_by_Id[graphData.nodes_by_Is["Articles"]].edges.contains;
      maxArticles = article_Ids.length;
      mapArticles = (function(_this) {
        return function(nodes) {
          var article_Id, article_Node, result, _i, _len;
          searchData.title = nodes.nodes_by_Id[nodes.nodes_by_Is["Search"]].text;
          searchData.resultsTitle = "" + article_Ids.length + "/" + maxArticles + " results showing";
          for (_i = 0, _len = article_Ids.length; _i < _len; _i++) {
            article_Id = article_Ids[_i];
            result = {
              title: null,
              link: null,
              id: null,
              summary: null,
              score: null
            };
            article_Node = nodes.nodes_by_Id[article_Id];
            result.title = article_Node.edges.title;
            result.summary = article_Node.edges.summary;
            result.guid = article_Node.edges.guid;
            result.id = article_Id;
            searchData.results.push(result);
          }
          return callback(searchData);
        };
      })(this);
      mapMetadata = (function(_this) {
        return function(nodes) {
          var article_Id, filter, metadata_Id, metadata_Node, query_Id, query_Ids, query_Node, result, xref_Article, xref_Id, _i, _j, _k, _len, _len1, _len2, _ref, _ref1;
          query_Ids = nodes.nodes_by_Id[nodes.nodes_by_Is["Metadatas"]].edges.contains;
          for (_i = 0, _len = query_Ids.length; _i < _len; _i++) {
            query_Id = query_Ids[_i];
            query_Node = nodes.nodes_by_Id[query_Id];
            filter = {};
            filter.title = query_Node.text;
            filter.results = [];
            _ref = query_Node.edges.contains;
            for (_j = 0, _len1 = _ref.length; _j < _len1; _j++) {
              metadata_Id = _ref[_j];
              metadata_Node = nodes.nodes_by_Id[metadata_Id];
              result = {
                title: metadata_Node.text,
                id: metadata_Id,
                size: metadata_Node.edges.xref.length
              };
              filter.results.push(result);
              if (filter_query === metadata_Id) {
                article_Ids = [];
                _ref1 = metadata_Node.edges.xref;
                for (_k = 0, _len2 = _ref1.length; _k < _len2; _k++) {
                  xref_Id = _ref1[_k];
                  xref_Article = nodes.nodes_by_Id[xref_Id];
                  article_Id = xref_Article.edges.target;
                  article_Ids.push(article_Id);
                }
              }
            }
            searchData.filters.push(filter);
          }
          return mapArticles(nodes);
        };
      })(this);
      mapContainers = (function(_this) {
        return function(nodes) {
          var article_Id, container, queries_Id, queries_Ids, query_Node, xref_Article, xref_Id, _i, _j, _len, _len1, _ref;
          queries_Ids = nodes.nodes_by_Id[nodes.nodes_by_Is["Queries"]].edges.contains;
          for (_i = 0, _len = queries_Ids.length; _i < _len; _i++) {
            queries_Id = queries_Ids[_i];
            query_Node = nodes.nodes_by_Id[queries_Id];
            container = {
              title: query_Node.text,
              id: queries_Id,
              size: query_Node.edges.xref.length
            };
            if (filter_container === queries_Id) {
              article_Ids = [];
              _ref = query_Node.edges.xref;
              for (_j = 0, _len1 = _ref.length; _j < _len1; _j++) {
                xref_Id = _ref[_j];
                xref_Article = nodes.nodes_by_Id[xref_Id];
                article_Id = xref_Article.edges.target;
                article_Ids.push(article_Id);
              }
            }
            searchData.containers.push(container);
          }
          return mapMetadata(nodes);
        };
      })(this);
      return mapContainers(graphData);
    };

    return GraphService;

  })();

  module.exports = GraphService;

}).call(this);
