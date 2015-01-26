require ('fluentnode')
GitHub_Service = require('./../../services/GitHub-Service')
expect         = require('chai').expect

describe 'services | test-GitHub-Service |', ->

    gitHubService = new GitHub_Service()
    
    @.timeout(3500)

    
    it 'test constructor', ->
        expect(GitHub_Service).to.be.an('Function')
        gitHubService = new GitHub_Service()
        expect(gitHubService        ).to.be.an('Object')
        expect(gitHubService.key    ).to.be.an('String')
        expect(gitHubService.secret ).to.be.an('String')
        expect(gitHubService.version).to.be.an('String')
        expect(gitHubService.debug  ).to.be.an('boolean')
        expect(gitHubService.github ).to.be.an('object')
        
    it 'authenticate',->
        expect(gitHubService.authenticate  ).to.be.an('Function')
        expect(gitHubService.authenticate()).to.equal(gitHubService)
        expect(gitHubService.github        ).to.not.equal (null)
        expect(gitHubService.github.auth   ).to.be.an('Object')
        
        expect(gitHubService.github.auth.type  ).to.equal('oauth')
        expect(gitHubService.github.auth.key   ).to.equal(gitHubService.key)
        expect(gitHubService.github.auth.secret).to.equal(gitHubService.secret)
        
    it 'rateLimit', (done)->
        expect(gitHubService.rateLimit  ).to.be.an('Function')
        gitHubService.rateLimit (data)->
            expect(data                     ).to.be.an('Object')
            expect(data.resources           ).to.be.an('Object')
            expect(data.resources.core      ).to.be.an('Object')
            expect(data.resources.core.limit).to.be.an('number')
            #console.log(data.resources.core)
            #console.log("\n remaining : " + data.resources.core.remaining)
            #console.log(" next reset: " + new Date(data.resources.core.reset * 1000).toLocaleTimeString())
            done()
            
    it 'gist_Raw', (done)->
        expect(gitHubService.gist_Raw  ).to.be.an('Function')
        gistId = "ad328585205f67569e0d"
        gitHubService.gist_Raw gistId, (data)->
            expect(data                     ).to.be.an('Object')
            files = Object.keys(data.files)
            expect(files).to.be.an("Array")
            expect(files).to.contain('Search_Data_Validation.json' )
            expect(files).to.contain('Search_Input_Validation.json')
            done()
            
    it 'gist', (done)->
        expect(gitHubService.gist  ).to.be.an('Function')
        gistId = "ad328585205f67569e0d"
        file   = 'Search_Data_Validation.json'
        
        gitHubService.gist gistId, file, (data)->
            expect(data).to.be.an('String')
            searchData = JSON.parse(data)
            
            expect(searchData      ).to.be.an('Object')
            expect(searchData.title).to.equal('Data Validation')

            gitHubService.gist gistId, 'abc', (data)->
                assert_Is_Null(data)
                done()
    
    it 'repo_Raw', (done)->
        expect(gitHubService.repo_Raw).to.be.an('Function')
        user = "TMContent"
        repo = "TM_Test_GraphData"
        gitHubService.repo_Raw user, repo, (data)->
            #console.log(data)
            expect(data).to.be.an('Object')
            done()
            
    it 'tree_Raw', (done)->
        expect(gitHubService.tree_Raw).to.be.an('Function')
        user   = "TMContent"
        repo   = "TM_Test_GraphData"
        sha    = 'master'
        gitHubService.tree_Raw user, repo, sha, (data)->
            #console.log(data)
            files = (item.path for item in data.tree)
            #console.log(files)
            #console.log("There were #{files.length} files")
            expect(data).to.be.an('Object')
            done()
    
    it 'file', (done)->
        expect(gitHubService.file).to.be.an('Function')
        user   = "TMContent"
        repo   = "TM_Test_GraphData"
        sha    = 'SearchData/Data_Validation.json'
        gitHubService.file user, repo, sha, (data)->
            expect(data).to.be.an('String')
            searchData = JSON.parse(data)
            expect(searchData      ).to.be.an('Object')
            expect(searchData.title).to.equal('Data Validation')
            done()