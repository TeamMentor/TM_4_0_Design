require('fluentnode')
fs            = require('fs'           )
expect        = require('chai'         ).expect
spawn         = require('child_process').spawn
Graph_Service  = require('./../../services/Graph-Service')

describe 'services | Graph-Service.test |', ->

    graphService  = null

    before ->
        graphService  = new Graph_Service()
        console.log

    it 'dataFromGitHub', (done)->
        expect(graphService.dataFromGitHub   ).to.be.an('Function')
        graphService.dataFromGitHub (data)->
            expect(data        ).to.be.an('Array')
            expect(data        ).to.not.be.empty
            expect(data.first()).to.not.be.empty
            
            expect(data.first().subject).to.be.an('String')
            expect(data.first().predicate).to.be.an('String')
            expect(data.first().object).to.be.an('String')
            done()

    it 'graphDataFromGraphDB', (done)->
        filters = ""
        queryId = 'Logging'
        graphService.graphDataFromGraphDB queryId, filters,  (searchData)=>
          searchData.assert_Is_Object()
          done()

    it 'graphDataFromGraphDB (non existent query)', (done)->
        queryId = 'AAAAAAA'.add_5_Random_Letters()
        graphService.graphDataFromGraphDB queryId, "",  (searchData)=>
            if (searchData.containers)
                searchData.containers.assert_Size_Is(0)          # regression test for [bug #128]
                searchData.filters.assert_Size_Is(0)
                searchData.results.assert_Size_Is(0)
            done()

    # This test to work will need a mocked (or real) tm graph instance running

    #it.only 'root_Queries',(done)->
    #  graphService.root_Queries (root_Queries)->
    #    log root_Queries
    #    done()
    #    return
    #    if not root_Queries
    #      done()
    #    else
    #      using root_Queries,->
    #        @.id        .assert_Is 'Root-Queries'
    #        @.title     .assert_Is 'Root Queries'
    #        @.containers.assert_Size_Is_Bigger_Than 4
    #        done()

    # move test below to a different describe since is affecting the graphService object
    it 'graphDataFromGraphDB (bad Server)', (done)->
        graphService.server = 'http://aaaaaaaa.teammentor.net'
        graphService.graphDataFromGraphDB '', '',  (searchData)=>
          searchData.assert_Is({})
          done()



#   it 'loadTestData', (done)->
#       expect(graphService.loadTestData).to.be.an('Function')
#       graphService.loadTestData () ->
#                                           expect(graphService.data).to.not.be.empty
#                                           expect(graphService.data.length).to.be.above(50)
#                                           #graphService.closeDb()
#                                           done()
#
#   it 'alldata', (done)->
#       expect(graphService.allData).to.be.an('Function')
#       graphService.allData  (err, data) ->
#                                               expect(data.length).to.equal(graphService.data.length)
#                                               done()
#   it 'query', (done)->
#       expect(graphService.query).to.be.an('Function')
#
#       items = [{ key : "subject"  , value: "bcea0b7ace25" , hasResults:true }
#                { key : "subject"  , value: "...."         , hasResults:false}
#                 { key : "predicate", value: "View"         , hasResults:true }
#                 { key : "predicate", value: "...."         , hasResults:false}
#                 { key : "object"   , value: "Design"       , hasResults:true }]
#        #items = []
#        checkItem = ->
#            if(items.empty())
#                done()
#            else
#                item = items.pop()
#                graphService.query item.key, item.value, (err, data)->
#                    if (item.hasResults)
#                        expect(data).to.not.be.empty
#                        expect(JSON.stringify(data)).to.contain(item.key)
#                        expect(JSON.stringify(data)).to.contain(item.value)
#                    else
#                        expect(data).to.be.empty
#                    checkItem()
#        checkItem()
#
     
#    it 'createSearchData' , (done)->
#
#        viewName          = 'Data Validation'
#        container_Title   = 'Perform Validation on the Server'
#        container_Id      = '4eef2c5f-7108-4ad2-a6b9-e6e84097e9e0'
#        container_Size    = 3
#        resultsTitle      = '8/8 results showing'
#        result_Title      = 'Client-side Validation Is Not Relied On'
#        result_Link       = 'https://tmdev01-uno.teammentor.net/9607b6e3-de61-4ff7-8ef0-9f8b44a5b27d'
#        result_Id         = '9607b6e3-de61-4ff7-8ef0-9f8b44a5b27d'
#        result_Summary    = 'Verify that the same or more rigorous checks are performed on the server as
#                             on the client. Verify that client-side validation is used only for usability
#                             and to reduce the number of posts to the server.'
#        result_Score      = 0
#        view_Title        = 'Technology'
#        view_result_Title = 'ASP.NET 4.0'
#        view_result_Size  = 1
#
#        checkSearchData = (data)->
#            #console.log(data)
#            expect(data             ).to.be.an('Object')
#            expect(data.title       ).to.be.an('String')
#            expect(data.containers  ).to.be.an('Array' )
#            expect(data.resultsTitle).to.be.an('String')
#            expect(data.results     ).to.be.an('Array' )
#            expect(data.filters     ).to.be.an('Array' )
#
#            expect(data.title                   ).to.equal(viewName)
#            expect(data.containers.first().title).to.equal(container_Title)
#            expect(data.containers.first().id   ).to.equal(container_Id   )
#            expect(data.containers.first().size ).to.equal(container_Size )
#            expect(data.resultsTitle            ).to.equal(resultsTitle   )
#            expect(data.results.first().title   ).to.equal(result_Title)
#            expect(data.results.first().link    ).to.equal(result_Link)
#            expect(data.results.first().id      ).to.equal(result_Id)
#            expect(data.results.first().summary ).to.equal(result_Summary)
#            expect(data.results.first().score   ).to.equal(result_Score)
#
#            firstFilter = data.filters.first()
#            expect(firstFilter.title                ).to.equal(view_Title)
#            expect(firstFilter.results              ).to.be.an('Array' )
#            expect(firstFilter.results.first().title).to.equal(view_result_Title)
#            expect(firstFilter.results.first().size ).to.equal(view_result_Size)
#
#            done()
#
#        graphService.createSearchData viewName, checkSearchData