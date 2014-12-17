/*jslint node: true */
"use strict";

//var preCompiler = require(process.cwd() + '/node/services/jade-pre-compiler.js');
var Jade_Service        = require('../services/Jade-Service')
//console.log(jade);

module.exports = function (app)
{
  var preCompiler =
    {
      renderJadeFile: function(path)
      {
        console.log('[renderJadeFile]' + path)
        return new Jade_Service(app.config).renderJadeFile(path)
      },
      cleanCacheFolder: function() {}
    }

  preCompiler.cleanCacheFolder();
//    var sourceDir = '../source';

    // special opitimized views (pre-compiled)

    app.get('/:version/articles/:page'        , function (req, res)  { res.send(preCompiler.renderJadeFile('/source/' + req.params.version + '/__ALL/articles/' + req.params.page + '.jade'));});
    app.get('/:version/error-pages/:page'     , function (req, res)  { res.send(preCompiler.renderJadeFile('/source/' + req.params.version + '/__ALL/error-pages/' + req.params.page + '.jade'));});
    app.get('/:version/getting-started/:page' , function (req, res)  { res.send(preCompiler.renderJadeFile('/source/' + req.params.version + '/__ALL/getting-started/' + req.params.page + '.jade'));});
    app.get('/:version/help/:page'            , function (req, res)  { res.send(preCompiler.renderJadeFile('/source/' + req.params.version + '/__ALL/help/' + req.params.page + '.jade'));});
    app.get('/:version/home/:page'            , function (req, res)  { res.send(preCompiler.renderJadeFile('/source/' + req.params.version + '/__ALL/home/' + req.params.page + '.jade'));});
    app.get('/:version/landing-pages/:page'   , function (req, res)  { res.send(preCompiler.renderJadeFile('/source/' + req.params.version + '/__ALL/landing-pages/' + req.params.page + '.jade'));});
    app.get('/:version/learning-paths/:page'  , function (req, res)  { res.send(preCompiler.renderJadeFile('/source/' + req.params.version + '/__ALL/learning-paths/' + req.params.page + '.jade'));});
    app.get('/:version/new-user-onboard/:page', function (req, res)  { res.send(preCompiler.renderJadeFile('/source/' + req.params.version + '/__ALL/new-user-onboard/' + req.params.page + '.jade'));});
    app.get('/:version/style-guide/:page'     , function (req, res)  { res.send(preCompiler.renderJadeFile('/source/' + req.params.version + '/__ALL/style-guide/' + req.params.page + '.jade'));});
    app.get('/:version/user/:page'            , function (req, res)  { res.send(preCompiler.renderJadeFile('/source/' + req.params.version + '/__ALL/user/' + req.params.page + '.jade'));});
    app.get('/:version/default'               , function (req, res)  { res.send(preCompiler.renderJadeFile('/source/' + req.params.version + '/__ALL/default.jade'));});
    app.get('/flare/all'                      , function (req, res)  { res.send(preCompiler.renderJadeFile('/source/flare/__ALL/index.jade'));});
    app.get('/flare'                          , function (req, res)  { res.redirect('/flare/all') });
    app.get('/flare/main-app-view'            , function (req, res)  { res.redirect('/flare/index') });

};