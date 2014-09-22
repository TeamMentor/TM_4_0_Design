config =  require('../config')
expect =  require('chai').expect

describe "test-config.js |", ->

    it "Ctor values", ->
    
        expect(config             ).to.be.an('Object')
        expect(config.cache_folder).to.be.an('String')        
        expect(config.cache_folder).to.equal(process.cwd()  + "./cacheFolder")
        expect(config.version     ).to.equal('0.1.0')
        