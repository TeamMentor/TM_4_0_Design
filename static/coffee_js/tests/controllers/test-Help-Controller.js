(function() {
  var Help_Controller, app, expect, request, supertest;

  supertest = require('supertest');

  expect = require('chai').expect;

  request = require('request');

  app = require('../../server');

  Help_Controller = require('../../controllers/Help-Controller.js');

  describe('controllers |', function() {
    return describe('test-Help-Controller.js |', function() {
      this.timeout(3500);
      describe('content_cache', function() {
        it('check ctor', function() {
          var help_Controller;
          help_Controller = new Help_Controller();
          expect(Help_Controller).to.be.an("Function");
          expect(help_Controller).to.be.an("Object");
          expect(help_Controller.content_cache).to.be.an("Object");
          expect(help_Controller.title).to.equal(null);
          return expect(help_Controller.content).to.equal(null);
        });
        return it('request should add to cache', function(done) {
          var checkRequestCache, help_Controller, page, req, res;
          page = 'index.html';
          req = {
            params: {
              page: page
            }
          };
          res = {
            status: function() {
              return this;
            }
          };
          help_Controller = new Help_Controller(req, res);
          help_Controller.content_cache[page] = void 0;
          checkRequestCache = function(html) {
            var cacheItem;
            cacheItem = help_Controller.content_cache[page];
            expect(cacheItem).to.be.an('Object');
            expect(cacheItem.title).to.equal(help_Controller.pageParams.title);
            expect(cacheItem.content).to.equal(help_Controller.pageParams.content);
            help_Controller.clearContentCache();
            expect(help_Controller.content_cache[page]).to.be.undefined;
            return done();
          };
          res.send = checkRequestCache;
          expect(help_Controller.content_cache).to.be.an('Object');
          return help_Controller.renderPage();
        });
      });
      return it('handle broken images bug', function(done) {
        var check_For_Redirect, check_That_Image_Exists, gitHub_Path, local_Path, test_image;
        gitHub_Path = 'https://raw.githubusercontent.com/TMContent/Lib_Docs/master/_Images/';
        local_Path = '/Image/';
        test_image = 'signup1.jpg';
        check_For_Redirect = function() {
          return supertest(app).get(local_Path + test_image).expect(302).end(function(error, response) {
            expect(response.headers).to.be.an('Object');
            expect(response.headers.location).to.be.an('String');
            expect(response.headers.location).to.equal(gitHub_Path + test_image);
            return check_That_Image_Exists(response.headers.location);
          });
        };
        check_That_Image_Exists = function(image_Path) {
          return request.get(image_Path, function(error, response) {
            expect(response.statusCode).to.equal(200);
            return done();
          });
        };
        return check_For_Redirect();
      });
    });
  });

}).call(this);
