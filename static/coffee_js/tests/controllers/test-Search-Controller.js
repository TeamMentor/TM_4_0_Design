(function() {
  var Config, Search_Controller, app, cheerio, expect, fs, supertest;

  fs = require('fs');

  supertest = require('supertest');

  expect = require('chai').expect;

  cheerio = require('cheerio');

  app = require('../../server');

  Config = require('../../Config');

  Search_Controller = require('../../controllers/Search-Controller');

  require('fluentnode');

  describe("controllers | test-Search-Controller |", function() {
    var searchController;
    this.timeout(3500);
    it("Ctor values", function() {
      var config, req, res, searchController;
      expect(Search_Controller).to.be.an('Function');
      req = {};
      res = {};
      config = new Config();
      searchController = new Search_Controller(req, res, config);
      expect(searchController).to.be.an('Object');
      expect(searchController.req).to.be.an('Object');
      expect(searchController.res).to.be.an('Object');
      expect(searchController.config).to.be.an('Object');
      expect(searchController.config).to.be.an('Object');
      expect(searchController.jade_Service).to.be.an('Object');
      expect(searchController.abc).to.not.be.an('Object');
      expect(searchController.req).to.equal(req);
      expect(searchController.res).to.equal(res);
      expect(searchController.config).to.equal(config);
      expect(searchController.searchData).to.equal(null);
      expect(searchController.jade_Page).to.equal('/source/jade/user/search.jade');
      expect(searchController.defaultUser).to.be.an('String');
      expect(searchController.defaultRepo).to.be.an('String');
      expect(searchController.defaultFolder).to.be.an('String');
      expect(searchController.defaultDataFile).to.be.an('String');
      expect(searchController.renderPage).to.be.an('Function');
      return expect(new Search_Controller().config).to.deep.equal(new Config());
    });
    searchController = new Search_Controller();
    searchController.config.enable_Jade_Cache = true;
    return xit('renderPage (and check content)', function() {
      var $, container, element, filter, formGroup, formGroupHtml, formGroups, html, mappedFilter, mappedFilters, result, searchData, title, _i, _j, _k, _l, _len, _len1, _len2, _len3, _ref, _ref1, _ref2, _results;
      searchController.config.enable_Jade_Cache = false;
      console.log('');
      searchController.searchData = null;
      html = searchController.renderPage();
      searchData = searchController.searchData;
      expect(searchData).to.be.an('Object');
      expect(html).to.be.an('String');
      expect(html).to.contain('<!DOCTYPE html>');
      $ = cheerio.load(html);
      expect($).to.be.an('Function');
      expect($('#title').html()).to.be.equal(searchData.title);
      expect($('#containers').html()).to.not.equal(null);
      expect($('#containers a').length).to.be.above(0);
      _ref = searchData.containers;
      for (_i = 0, _len = _ref.length; _i < _len; _i++) {
        container = _ref[_i];
        element = $("#" + container.id);
        expect(element.html()).to.not.be["null"];
        expect(element.html()).to.contain(container.title);
        expect(element.html()).to.contain(container.size);
      }
      expect($('#resultsTitle').html()).to.equal(searchData.resultsTitle);
      _ref1 = searchData.results;
      for (_j = 0, _len1 = _ref1.length; _j < _len1; _j++) {
        result = _ref1[_j];
        element = $("#" + result.id);
        expect(element.html()).to.not.be["null"];
        expect(element.attr('id')).to.equal(result.id);
        expect(element.attr('href')).to.equal(result.link);
        expect(element.find('h4').html()).to.equal(result.title);
        expect(element.find('p').html()).to.equal(result.summary);
      }
      mappedFilters = {};
      _ref2 = searchData.filters;
      for (_k = 0, _len2 = _ref2.length; _k < _len2; _k++) {
        filter = _ref2[_k];
        mappedFilters[filter.title] = filter;
      }
      expect($('#filters').html()).to.not.equal(null);
      expect($('#filters h3').html()).to.equal('Filters');
      expect($('#filters form').html()).to.not.equal(null);
      expect($('#filters form .form-group').html()).to.not.equal(null);
      formGroups = $('#filters form .form-group');
      expect(formGroups.length).to.equal(searchData.filters.length);
      _results = [];
      for (_l = 0, _len3 = formGroups.length; _l < _len3; _l++) {
        formGroup = formGroups[_l];
        title = $(formGroup).find('h5').html();
        expect(title).to.be.an('String');
        mappedFilter = mappedFilters[title];
        expect(mappedFilter).to.be.an('Object');
        formGroupHtml = $(formGroup).html();
        _results.push((function() {
          var _len4, _m, _ref3, _results1;
          _ref3 = mappedFilter.results;
          _results1 = [];
          for (_m = 0, _len4 = _ref3.length; _m < _len4; _m++) {
            result = _ref3[_m];
            expect(formGroupHtml).to.contain(result.title);
            _results1.push(expect(formGroupHtml).to.contain(result.size));
          }
          return _results1;
        })());
      }
      return _results;
    });
  });

}).call(this);
