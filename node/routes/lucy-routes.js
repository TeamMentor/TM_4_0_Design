/*jslint node: true */
"use strict";

var auth = require('./lucy-auth'),
    preCompiler = require(process.cwd() + '/node/services/jade-pre-compiler.js');

//console.log(jade);


module.exports = function (app)
{
    preCompiler.cleanCacheFolder();
//    var sourceDir = '../source';

    // special opitimized views (pre-compiled)

    app.get('/:version/:page', function (req, res)  { res.send(preCompiler.renderJadeFile('/source/' + req.params.version + '/' + req.params.page + '.jade'));});

    app.get('/:version/articles/:page.html', function (req, res)  { res.send(preCompiler.renderJadeFile('/source/' + req.params.version + '/articles/' + req.params.page + '.jade'));});

    app.get('/:area/getting-started/:page.html', function (req, res)  { res.send(preCompiler.renderJadeFile('/source/' + req.params.area + '/articles/' + req.params.page + '.jade'));});

    app.get('/:area/home/:page.html', function (req, res)  { res.send(preCompiler.renderJadeFile('/source/' + req.params.area + '/home/' + req.params.page + '.jade'));});

    app.get('/:area/landing-pages/:page.html', function (req, res)  { res.send(preCompiler.renderJadeFile('/source/' + req.params.area + '/landing-pages/' + req.params.page + '.jade'));});

    // This directory doesn't exist anymore - app.get('/user/login/:page.html'                        , function (req, res)  { res.send(preCompiler.renderJadeFile('/source/html/user/login/'              + req.params.page + '.jade'                       ));});

    // app.get('/:area/:page.html'            , auth.checkAuth , function (req, res)  { res.send(preCompiler.renderJadeFile('/source/'  + '/' + req.params.area + '/' + req.params.page + '.jade'));});

    //Redirect to Jade pages
    app.get('/', function (req, res)  { res.send(preCompiler.renderJadeFile('/source/index.jade'));});
    // app.get('/deploy/html/:area/:page.html'                 , function (req, res)  { res.redirect('/'                 + req.params.area +'/'+req.params.page + '.html');});

    //Render Jade pages (old with no precompilation)
    //app.get('/:page.html'                                    , function (req, res)  { res.render  (sourceDir + '/html/'+ req.params.page                      + '.jade');});
    //app.get('/user/login/:page.html'                        , function (req, res)  { res.render  (sourceDir + '/html/user/login/'   + req.params.page + '.jade');});
    //app.get('/landing-pages/:page.html'                     , function (req, res)  { res.render  (sourceDir + '/html/landing-pages/'+ req.params.page + '.jade');});

    //app.get('/help/:page.html'                              , function (req, res)  { res.render  (sourceDir + '/html/help/' + req.params.page + '.jade', auth.mappedAuth(req));});
    //app.get('/:area/:page.html'            , auth.checkAuth , function (req, res)  { res.render  (sourceDir + '/html/'      + req.params.area +'/'+req.params.page + '.jade');});
};