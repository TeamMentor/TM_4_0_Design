/*jslint node: true , expr:true */
/*global describe, it, before, after */
"use strict";

var supertest = require('supertest')   ,
    expect    = require('chai').expect ,
    cheerio   = require('cheerio')     ,
    app       = require('../../server');

describe('pages', function () 
{
    before(function() { app.server = app.listen(app.port);   });
    after (function() { app.server.close();                  });
        
    describe('test-help__index.js', function() 
    {   
        it('should open page ok', function(done)
        {
            supertest(app).get('/help/index.html')
                          .expect(200,done); 
        });
        
        it('open /default.html', function(done)
        {            
            supertest(app).get('/default.html')
                          .expect(200)
                          .end(function(err, res)
                               {
                                    if(err) { throw err; }
                                    var $ = cheerio.load(res.text);
                                    expect($('a').length).to.be.above(10);
                                    expect($("a[href='/help/aaaaa.html'] ").length).to.be.empty;
                                    expect($("a[href='/help/index.html']" ).length).to.be.not.empty;                                                                        
                                    done();
                               });
        });        
        
        it('open help from /default.html', function(done)
        {
            supertest(app).get('/default.html')
                          .expect(200)
                          .end(function(err, res)
                               {
                                    var $ = cheerio.load(res.text);
                                    var helpImgTag    = $("img[src='/deploy/assets/icons/help.png']").parent();
                                    var helpAnchorTag = helpImgTag.parent();
                
                                    expect(helpImgTag   ).to.be.an('object');
                                    expect(helpAnchorTag).to.be.an('object');
                
                                    expect(helpImgTag   .html()).to.equal('<img src="/deploy/assets/icons/help.png" alt="Help">');
                                    expect(helpAnchorTag.html()).to.equal('<a href="/help/index.html"><img src="/deploy/assets/icons/help.png" alt="Help"></a>');
                                    
                                    var helpUrl = helpAnchorTag.find('a').attr('href');                          
                                    expect(helpUrl).to.equal('/help/index.html');
                                    
                                    supertest(app).get(helpUrl)
                                                 .expect(200, done);
                
                               });            
        });
        
    });
});