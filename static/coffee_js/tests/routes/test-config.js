(function() {
  var app, expect, supertest;

  app = require('../../server');

  expect = require('chai').expect;

  supertest = require('supertest');

  describe("routes | test-config.coffee |", function() {
    it("/version", function(done) {
      return supertest(app).get('/version').expect(200, app.config.version, done);
    });
    return it("/config", function(done) {
      return supertest(app).get('/config').expect(200, app.config, done);
    });
  });

}).call(this);
