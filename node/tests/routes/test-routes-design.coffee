app       = require('../../server')
expect    = require('chai').expect
supertest = require('supertest')

describe.only "routes | test-routes-design |", ->
    
    routes = [ { url: "/articles/article-new-window-view.html" , status: 200 }
               { url: "/articles/fundamentals-of-security.html", status: 200 }
               { url: "/articles/my-articles-edit.html"        , status: 200 }
               { url: "/articles/my-articles.html"             , status: 200 }
               { url: "/articles/my-search-items.html"         , status: 200 }
               { url: "/articles/owasp.html"                   , status: 200 }
               { url: "/home/app-keyword-search.html"          , status: 200 }
               { url: "/home/filters-active.html"              , status: 200 }
               { url: "/user/main.html"                        , status: 200 }
             ]
    
    before ->
        app.config.enable_Jade_Cache = true
        app.config.disableAuth       = true
    
    after ->
        app.config.disableAuth       = false
    
    
    runTest = (route) ->
        it route.url, (done) ->
            console.log route.url
            checkreponse = (error,response) ->
                expect(error).to.equal(null)
                expect(response.text).to.not.equal('')
                done()
            supertest(app).get(route.url)
                         .expect(route.status,checkreponse)
                

                          
    for route in routes
        runTest(route)
