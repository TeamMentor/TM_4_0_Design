(function() {
  var app, supertest;

  supertest = require('supertest');

  app = require('../../server');

  describe('routes | test-routes.js |', function() {
    var expectedPaths, route, runTest, _i, _len, _results;
    expectedPaths = ['/', '/flare/:area/:page', '/flare/default', '/Image/:name', '/article/view/:guid/:title', '/config', '/deploy/html/:area/:page.html', '/dirName', '/flare', '/flare/all', '/flare/main-app-view', '/graph/:queryId', '/graph/:queryId/:filters', '/guest/:page.html', '/help/:page*', '/index.html', '/libraries', '/library/:library/folder/:folder', '/library/:name', '/library/queries', '/mainModule', '/module', '/ping', '/pwd', '/session', '/test', '/user/login', '/user/login', '/user/logout', '/user/main.html', '/user/pwd_reset', '/user/sign-up', '/version'];
    before(function() {
      return app.server = app.listen();
    });
    after(function() {
      return app.server.close();
    });
    it('Check expected paths', function() {
      var paths, routes;
      paths = [];
      routes = app._router.stack;
      routes.forEach(function(item) {
        if (item.route) {
          return paths.push(item.route.path);
        }
      });
      paths.length.assert_Is(expectedPaths.length);
      return paths.forEach(function(path) {
        return expectedPaths.assert_Contains(path);
      });
    });
    runTest = function(originalPath) {
      var expectedStatus, path, postRequest, testName;
      path = originalPath.replace(':version', 'flare').replace(':area/:page', 'help/index').replace(':page', 'default').replace(':queryId', 'AAAA').replace(':filters', 'BBBB');
      expectedStatus = 200;
      if (['image', 'deploy'].contains(path.split('/').second().lower())) {
        expectedStatus = 302;
      }
      if (['/flare', '/flare/main-app-view', '/user/login', '/user/logout', '/user/sign-up'].contains(path)) {
        expectedStatus = 302;
      }
      if (['article', 'graph', 'library', 'libraries'].contains(path.split('/').second().lower())) {
        expectedStatus = 403;
      }
      if (['/user/main.html'].contains(path)) {
        expectedStatus = 403;
      }
      postRequest = ['/user/pwd_reset', '/user/sign-up'].contains(path);
      testName = ("[" + expectedStatus + "] " + originalPath) + (path !== originalPath ? "  (" + path + ")" : "");
      return it(testName, function(done) {
        var checkResponse;
        checkResponse = function(error, response) {
          assert_Is_Null(error);
          response.text.assert_Is_String();
          return done();
        };
        if (postRequest) {
          return supertest(app).post(path).send({}).expect(expectedStatus, checkResponse);
        } else {
          return supertest(app).get(path).expect(expectedStatus, checkResponse);
        }
      });
    };
    _results = [];
    for (_i = 0, _len = expectedPaths.length; _i < _len; _i++) {
      route = expectedPaths[_i];
      _results.push(runTest(route));
    }
    return _results;
  });

}).call(this);
