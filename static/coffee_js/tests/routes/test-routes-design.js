(function() {
  var app, expect, supertest;

  app = require('../../server');

  expect = require('chai').expect;

  supertest = require('supertest');

  describe("routes | test-routes-design |", function() {
    var route, routes, runTest, _i, _len, _results;
    routes = [
      {
        url: "/articles/article-new-window-view.html",
        status: 200
      }, {
        url: "/articles/fundamentals-of-security.html",
        status: 200
      }, {
        url: "/articles/my-articles-edit.html",
        status: 200
      }, {
        url: "/articles/my-articles.html",
        status: 200
      }, {
        url: "/articles/my-search-items.html",
        status: 200
      }, {
        url: "/articles/owasp.html",
        status: 200
      }, {
        url: "/home/app-keyword-search.html",
        status: 200
      }, {
        url: "/home/filters-active.html",
        status: 200
      }, {
        url: "/user/main.html",
        status: 200
      }
    ];
    before(function() {
      app.config.enable_Jade_Cache = true;
      return app.config.disableAuth = true;
    });
    after(function() {
      return app.config.disableAuth = false;
    });
    runTest = function(route) {
      return it(route.url, function(done) {
        var checkreponse;
        checkreponse = function(error, response) {
          expect(error).to.equal(null);
          expect(response.text).to.not.equal('');
          return done();
        };
        return supertest(app).get(route.url).expect(route.status, checkreponse);
      });
    };
    _results = [];
    for (_i = 0, _len = routes.length; _i < _len; _i++) {
      route = routes[_i];
      _results.push(runTest(route));
    }
    return _results;
  });

}).call(this);
