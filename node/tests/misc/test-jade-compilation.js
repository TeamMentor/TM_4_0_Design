/*jslint node: true , expr:true */
/*global describe, it */

var jade   = require("jade"),
    fs     = require('fs'),
    expect = require("chai").expect;


//used to understand better how jade compilation works (specialy how it compiles to java script)
describe("misc > test-jade-compilation.js", function()
{    
    it('render and compile jade', function()
    {   
        expect(jade.render("doctype html")).to.equal('<!DOCTYPE html>');         
        expect(jade.render("div 123"     )).to.equal('<div>123</div>');
        expect(jade.render("pre 123"     )).to.equal('<pre>123</pre>');
        
        expect(jade.render("div= name", {name : 'abc' }) ).to.equal('<div>abc</div>');
        expect(jade.compile("pre 123").toString()).to.equal('function (locals){ return fn(locals, Object.create(runtime)) }');
        
        var fn = jade.compileClient("pre abc", { compileDebug : false});
        expect(fn).to.contain('buf.push("<pre>abc</pre>");;return buf.join("");');
        //console.log(fn);            // use to see full compiled script        
    });
    
    it('compile into file and executed it', function()
    {
        var tempFile = '_testJadeCompile.js';
        var filePath = process.cwd() + '/node/_jade_PreCompiled/' + tempFile;
        var compiledJade = jade.compileClient("pre= abc", { compileDebug : false});
        var exportCode =  'var jade = require(\'jade/lib/runtime.js\'); \n' + 
                          'module.exports = ' + compiledJade;
        
        fs.writeFileSync(filePath,exportCode);
        
        var readCode = fs.readFileSync(filePath, "utf8");
        
        expect(readCode).to.equal(exportCode);
        
        var loadedRequire = require(filePath);
        
        expect(loadedRequire  ).to.be.an('function');
        expect(loadedRequire()).to.be.an('string');
        expect(loadedRequire()).to.equal('<pre></pre>');
        expect(loadedRequire({abc : '123'} )).to.equal('<pre>123</pre>');
        
        expect(fs.existsSync(filePath)).to.be.true;
        
        fs.unlinkSync(filePath);
        
        expect(fs.existsSync(filePath)).to.be.false;
        
    });
    
    it('compile help file', function()
    {
        var helpJadeFile = process.cwd() + '/source/html/help/index.jade';

        expect(fs.existsSync(helpJadeFile)).to.be.true;
        
        var helpJadeFile_Contents = fs.readFileSync(helpJadeFile,  "utf8");        
        var helpJadeFile_Compiled = jade.compileClient(helpJadeFile_Contents , { filename:helpJadeFile, compileDebug : false} );
        
        
        expect(helpJadeFile_Contents).to.contain('h3.dark-grey TEAM Mentor Related Sites');
        expect(helpJadeFile_Compiled).to.contain('><h3 class=\\"dark-grey\\">TEAM Mentor Related Sites</h3>');
        
        var exportCode =  'var jade = require(\'jade/lib/runtime.js\'); \n' + 
                          'module.exports = ' + helpJadeFile_Compiled;
        
        var filePath = process.cwd() + '/node/_jade_PreCompiled/' + "help.index.js";
        fs.writeFileSync(filePath,exportCode);
        var loadedRequire = require(filePath);
        
        expect(loadedRequire  ).to.be.an('function');
        expect(loadedRequire()).to.be.an('string');
                
        expect(loadedRequire()                ).to.contain    ('<a href="/deploy/html/landing-pages/about.html">About</a>'); 
        expect(loadedRequire({loggedIn:false})).to.contain    ('<a href="/deploy/html/landing-pages/about.html">About</a>'); 
        expect(loadedRequire({loggedIn:true })).to.not.contain('<a href="/deploy/html/landing-pages/about.html">About</a>'); 
        expect(loadedRequire({loggedIn:false})).to.not.contain('<img src="/deploy/assets/icons/help.png" alt="Help">'); 
        expect(loadedRequire({loggedIn:true })).to.contain    ('<img src="/deploy/assets/icons/help.png" alt="Help">'); 
    });
});
