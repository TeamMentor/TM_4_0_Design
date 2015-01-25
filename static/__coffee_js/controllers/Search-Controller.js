(function() {
  var Config, GitHub_Service, Graph_Service, Jade_Service, SearchController, auth, breadcrumbs_Cache, fs, path, recentArticles_Cache, request,
    __bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; };

  fs = require('fs');

  path = require('path');

  request = require('request');

  Config = require('../Config');

  auth = require('../middleware/auth');

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
      return this.jade_Service.renderJadeFile(this.jade_Page, this.searchData);
    };


    /*
     search : ()=>
        server = 'http://localhost:1332';
        url    = '/data/tm-uno/queries';
        text = @req.query.text
        
        request server + url, (error, response,data) =>
            graph = JSON.parse(data);
            nodes = graph.nodes;
            node_Labels = [];
            nodes.forEach (node)=> node_Labels.push(node.label)
            allQueries =  node_Labels.sort();
            foundQuery = ""
            if (allQueries.contains(text))
                foundQuery = text
            else
                text = text.lower()
                foundQuery = query for query in allQueries when query.lower().indexOf(text) > -1
            if (foundQuery == "")
                @res.redirect('/user/main.html')
            else            
                @res.redirect("/graph/#{foundQuery}")
     */

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
          console.log('....');
          if (true) {
            (function() {
              var item, recentArticle, recentArticles, searchTerms, _i, _j, _len, _len1;
              data = JSON.parse(data).splice(0, 4);
              console.log(data);
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
              viewModel = {
                recentArticles: recentArticles,
                topArticles: topArticles,
                searchTerms: searchTerms
              };
              return log(viewModel);
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
    app.get('/graph/:queryId', (function(req, res, next) {
      return auth.checkAuth(req, res, next, app.config);
    }), function(req, res) {
      return new SearchController(req, res, app.config).showSearchFromGraph();
    });
    app.get('/graph/:queryId/:filters', (function(req, res, next) {
      return auth.checkAuth(req, res, next, app.config);
    }), function(req, res) {
      return new SearchController(req, res, app.config).showSearchFromGraph();
    });
    app.get('/user/main.html', (function(req, res, next) {
      return auth.checkAuth(req, res, next, app.config);
    }), function(req, res) {
      return new SearchController(req, res, app.config).showMainAppView();
    });
    return app.get('/article/view/:guid/:title', (function(req, res, next) {
      return auth.checkAuth(req, res, next, app.config);
    }), function(req, res) {
      return new SearchController(req, res, app.config).showArticle();
    });
  };

  module.exports = SearchController;

}).call(this);
