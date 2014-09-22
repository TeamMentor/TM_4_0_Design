app = require('../server')

expect =  require('chai').expect

describe "test-server.js |", ->

    it "Ctor values", ->
    
        expect(app              ).to.be.an('Function')
        expect(app.config       ).to.be.an('Object')
        expect(app._router.stack).to.be.an('Array')
        
