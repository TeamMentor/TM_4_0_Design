(function() {
  var app, expect;

  app = require('../server');

  expect = require('chai').expect;

  describe("test-server.js |", function() {
    return it("Ctor values", function() {
      expect(app).to.be.an('Function');
      expect(app.config).to.be.an('Object');
      return expect(app._router.stack).to.be.an('Array');
    });
  });

}).call(this);
