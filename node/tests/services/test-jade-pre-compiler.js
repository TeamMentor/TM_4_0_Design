/*jslint node: true , expr:true */
/*global describe, it */

var jade        = require("jade"),
    fs          = require('fs'),
    expect      = require("chai").expect,
    preCompiler = require('../../services/jade-pre-compiler.js');


//used to understand better how jade compilation works (specialy how it compiles to java script) 
describe("services > jade-pre-compiler.js", function()
{    
    preCompiler.disableCache = false;
    
    it('check preCompiler object', function()
    {   
        expect(preCompiler                      ).to.be.an('object');
        expect(preCompiler._targetFolder        ).to.be.an('String');
        
        expect(preCompiler.compileJadeFileToDisk).to.be.an('function');
        expect(preCompiler.calculateTargetPath  ).to.be.an('function');
        
        
        expect(preCompiler._targetFolder).to.equal('/node/_jade_PreCompiled/');
    });
    
    it('calculateTargetPath', function()
    {
        var calculateTargetPath = preCompiler.calculateTargetPath;
        var targetFolder        = preCompiler.targetFolder();
        expect(targetFolder       ).to.equal(process.cwd() + preCompiler._targetFolder);
        expect(calculateTargetPath).to.be.an('function');
        expect(calculateTargetPath('aaa'             )).to.equal(targetFolder + 'aaa.txt'             );       // if the compiled jade file is 
        expect(calculateTargetPath('aaa/bbb'         )).to.equal(targetFolder + 'aaa_bbb.txt'         );       // and .js , we will have a circular auto compilation
        expect(calculateTargetPath('aaa/bbb/ccc'     )).to.equal(targetFolder + 'aaa_bbb_ccc.txt'     );       // when running the tests using (for example)
        expect(calculateTargetPath('aaa/bbb.jade'    )).to.equal(targetFolder + 'aaa_bbb_jade.txt'    );       //     mocha -w node/tests/**/*jade*.js -R list
        expect(calculateTargetPath('aaa/bbb.ccc.jade')).to.equal(targetFolder + 'aaa_bbb_ccc_jade.txt');
        
    });
            
    it('compileJadeFileToDisk', function()
    {
        var compileJadeFileToDisk = preCompiler.compileJadeFileToDisk,
            //helpJadeFile    = '/source/html/help/index.jade',
            defaultJadeFile = '/source/html/default.jade';
        
        expect(compileJadeFileToDisk('a')).to.be.false;
        //expect(compileJadeFileToDisk(helpJadeFile)).to.be.true;
        expect(compileJadeFileToDisk(defaultJadeFile)).to.be.true;
        
        var targetPath    = preCompiler.calculateTargetPath(defaultJadeFile);
        var jadeTemplate  = require(targetPath);
        expect(jadeTemplate  ).to.be.an('function');
        expect(jadeTemplate()).to.be.an('string');
        
        var html = jadeTemplate();
        expect(html).to.contain('<!DOCTYPE html><html lang="en"><head> ');
        
    });
    it('renderJadeFile', function()
    {        
         var renderJadeFile = preCompiler.renderJadeFile,
             helpJadeFile    = '/source/html/help/index.jade'; 
        
        expect(renderJadeFile('a')).to.be.equal("");
        
        expect(renderJadeFile(helpJadeFile, { structure: []})).to.not.be.equal("");        
        expect(renderJadeFile(helpJadeFile                 )).to.contain    ('<a href="/deploy/html/landing-pages/about.html">About</a>'); 
        expect(renderJadeFile(helpJadeFile,{loggedIn:false})).to.contain    ('<a href="/deploy/html/landing-pages/about.html">About</a>'); 
        expect(renderJadeFile(helpJadeFile,{loggedIn:true })).to.not.contain('<a href="/deploy/html/landing-pages/about.html">About</a>'); 
        expect(renderJadeFile(helpJadeFile,{loggedIn:false})).to.not.contain('<img src="/deploy/assets/icons/help.png" alt="Help">'); 
        expect(renderJadeFile(helpJadeFile,{loggedIn:true })).to.contain    ('<img src="/deploy/assets/icons/help.png" alt="Help">'); 
    });
});