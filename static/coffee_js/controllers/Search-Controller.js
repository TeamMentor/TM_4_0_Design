(function() {
  var Config, GitHub_Service, Graph_Service, Jade_Service, SearchController, breadcrumbs_Cache, fs, path, recentArticles_Cache, request,
    __bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; };

  fs = require('fs');

  path = require('path');

  Config = require('../Config');

  request = require('request');

  Jade_Service = require('../services/Jade-Service');

  GitHub_Service = require('../services/GitHub-Service');

  Graph_Service = require('../services/Graph-Service');

  recentArticles_Cache = [];

  breadcrumbs_Cache = [];

  SearchController = (function() {
    function SearchController(req, res, config) {
      this.showArticle = __bind(this.showArticle, this);
      this.showMainAppView = __bind(this.showMainAppView, this);
      this.showSearchFromGraph = __bind(this.showSearchFromGraph, this);
      this.search = __bind(this.search, this);
      this.req = req;
      this.res = res;
      this.config = config || new Config();
      this.jade_Page = '/source/jade/user/search.jade';
      this.jade_Service = new Jade_Service(this.config);
      this.searchData = null;
      this.defaultUser = "TMContent";
      this.defaultRepo = "TM_Test_GraphData";
      this.defaultFolder = '/SearchData/';
      this.defaultDataFile = 'Data_Validation';
    }

    SearchController.prototype.renderPage = function() {
      if (!this.searchData) {
        this.loadSearchData();
      }
      return this.jade_Service.renderJadeFile(this.jade_Page, this.searchData);
    };

    SearchController.prototype.search = function() {
      var server, text, url;
      server = 'http://localhost:1332';
      url = '/data/tm-uno/queries';
      text = this.req.query.text;
      return request(server + url, (function(_this) {
        return function(error, response, data) {
          var allQueries, foundQuery, graph, node_Labels, nodes, query, _i, _len;
          graph = JSON.parse(data);
          nodes = graph.nodes;
          node_Labels = [];
          nodes.forEach(function(node) {
            return node_Labels.push(node.label);
          });
          allQueries = node_Labels.sort();
          foundQuery = "";
          if (allQueries.contains(text)) {
            foundQuery = text;
          } else {
            text = text.lower();
            for (_i = 0, _len = allQueries.length; _i < _len; _i++) {
              query = allQueries[_i];
              if (query.lower().indexOf(text) > -1) {
                foundQuery = query;
              }
            }
          }
          if (foundQuery === "") {
            return _this.res.redirect('/user/main.html');
          } else {
            return _this.res.redirect("/graph/" + foundQuery);
          }
        };
      })(this));
    };

    SearchController.prototype.showSearchFromGraph = function() {
      var filters, graphService, queryId;
      queryId = this.req.params.queryId;
      filters = this.req.params.filters;
      console.log(queryId);
      breadcrumbs_Cache = breadcrumbs_Cache.splice(0, 3);
      if (filters) {
        breadcrumbs_Cache.unshift({
          href: "/graph/" + queryId + "/" + filters,
          title: filters
        });
      } else {
        breadcrumbs_Cache.unshift({
          href: "/graph/" + queryId,
          title: queryId
        });
      }
      graphService = new Graph_Service();
      return graphService.graphDataFromGraphDB(null, queryId, filters, (function(_this) {
        return function(searchData) {
          searchData.filter_container = filters;
          _this.searchData = searchData;
          searchData.breadcrumbs = breadcrumbs_Cache;
          return _this.res.send(_this.renderPage());
        };
      })(this));
    };

    SearchController.prototype.showSearchData = function() {
      return this.res.set('Content-Type', 'application/json').send(JSON.stringify(this.loadSearchData().searchData, null, ' '));
    };

    SearchController.prototype.showMainAppView = function() {
      var topArticles;
      breadcrumbs_Cache.unshift({
        href: "/user/main.html",
        title: "Search Home"
      });
      topArticles = 'http://localhost:1332/data/tm-data/articles-by-weight';
      return request(topArticles, (function(_this) {
        return function(err, response, data) {
          var jadePage, viewModel;
          console.log("data" + data);
          jadePage = '../source/jade/user/main.jade';
          viewModel = {};
          if (false) {
            (function() {
              var item, recentArticle, recentArticles, searchTerms, _i, _j, _len, _len1;
              data = JSON.parse(data).splice(0, 4);
              topArticles = [];
              for (_i = 0, _len = data.length; _i < _len; _i++) {
                item = data[_i];
                topArticles.push({
                  href: "/article/view/" + item.guid + "/" + item.title,
                  title: "" + item.title,
                  weight: "" + item.weight
                });
              }
              searchTerms = [];
              searchTerms.push({
                href: "/graph/Logging",
                title: "Logging"
              });
              searchTerms.push({
                href: "/graph/Separation%20of%20Data%20and%20Control",
                title: "Separation of Data and Control"
              });
              searchTerms.push({
                href: "/graph/(Web) Encoding",
                title: "(Web) Encoding"
              });
              recentArticles = [];
              for (_j = 0, _len1 = recentArticles_Cache.length; _j < _len1; _j++) {
                recentArticle = recentArticles_Cache[_j];
                recentArticles.push({
                  href: 'https://tmdev01-uno.teammentor.net/' + recentArticle.guid,
                  title: recentArticle.title
                });
                if (recentArticles.length > 2) {
                  break;
                }
              }
              return viewModel = {
                recentArticles: recentArticles,
                topArticles: topArticles,
                searchTerms: searchTerms
              };
            });
          }
          console.log("jadePage: " + jadePage);
          return _this.res.render(jadePage, viewModel);
        };
      })(this));
    };

    SearchController.prototype.showArticle = function() {
      var guid, title;
      guid = this.req.params.guid;
      title = this.req.params.title;
      recentArticles_Cache.unshift({
        guid: guid,
        title: title
      });
      return this.res.redirect('https://tmdev01-uno.teammentor.net/' + guid);
    };

    return SearchController;

  })();

  SearchController.registerRoutes = function(app) {
    app.get('/search', function(req, res) {
      return new SearchController(req, res, app.config).search();
    });
    app.get('/graph/:queryId', function(req, res) {
      return new SearchController(req, res, app.config).showSearchFromGraph();
    });
    app.get('/graph/:queryId/:filters', function(req, res) {
      return new SearchController(req, res, app.config).showSearchFromGraph();
    });
    app.get('/user/main.html', function(req, res) {
      return new SearchController(req, res, app.config).showMainAppView();
    });
    return app.get('/article/view/:guid/:title', function(req, res) {
      return new SearchController(req, res, app.config).showArticle();
    });
  };

  module.exports = SearchController;

}).call(this);
