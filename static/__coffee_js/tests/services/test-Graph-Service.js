(function() {
  var Graph_Service, expect, fs, spawn;

  require('fluentnode');

  fs = require('fs');

  expect = require('chai').expect;

  spawn = require('child_process').spawn;

  Graph_Service = require('./../../services/Graph-Service');

  describe('test-Graph-Service |', function() {
    var graphService;
    graphService = new Graph_Service();
    return it('dataFromGitHub', function(done) {
      expect(graphService.dataFromGitHub).to.be.an('Function');
      return graphService.dataFromGitHub(function(data) {
        expect(data).to.be.an('Array');
        expect(data).to.not.be.empty;
        expect(data.first()).to.not.be.empty;
        expect(data.first().subject).to.be.an('String');
        expect(data.first().predicate).to.be.an('String');
        expect(data.first().object).to.be.an('String');
        return done();
      });
    });
  });

}).call(this);
