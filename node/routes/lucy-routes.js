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

    app.get('/:version/articles/:page', auth.checkAuth, function (req, res)  { res.send(preCompiler.renderJadeFile('/source/' + req.params.version + '/articles/' + req.params.page + '.jade'));});

    app.get('/:version/getting-started/:page', function (req, res)  { res.send(preCompiler.renderJadeFile('/source/' + req.params.version + '/getting-started/' + req.params.page + '.jade'));});

    app.get('/:version/help/:page', function (req, res)  { res.send(preCompiler.renderJadeFile('/source/' + req.params.version + '/help/' + req.params.page + '.jade'));});

    app.get('/:version/home/:page', auth.checkAuth, function (req, res)  { res.send(preCompiler.renderJadeFile('/source/' + req.params.version + '/home/' + req.params.page + '.jade'));});

    app.get('/:version/landing-pages/:page', function (req, res)  { res.send(preCompiler.renderJadeFile('/source/' + req.params.version + '/landing-pages/' + req.params.page + '.jade'));});

    app.get('/:version/learning-paths/:page', function (req, res)  { res.send(preCompiler.renderJadeFile('/source/' + req.params.version + '/learning-paths/' + req.params.page + '.jade'));});

    app.get('/:version/new-user-onboard/:page', function (req, res)  { res.send(preCompiler.renderJadeFile('/source/' + req.params.version + '/new-user-onboard/' + req.params.page + '.jade'));});

    app.get('/:version/style-guide/:page', function (req, res)  { res.send(preCompiler.renderJadeFile('/source/' + req.params.version + '/style-guide/' + req.params.page + '.jade'));});

    app.get('/:version/user/:page', function (req, res)  { res.send(preCompiler.renderJadeFile('/source/' + req.params.version + '/user/' + req.params.page + '.jade'));});

    app.get('/:version/default', function (req, res)  { res.send(preCompiler.renderJadeFile('/source/' + req.params.version + '/default.jade'));});

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