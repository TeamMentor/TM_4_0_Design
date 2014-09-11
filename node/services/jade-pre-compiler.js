/*jslint node: true */

var fs   = require('fs'),
    jade = require('jade');

var preCompiler = 
    {
        _targetFolder : '/node/_jade_PreCompiled/'
    };

                
preCompiler.calculateTargetPath   = function(fileToCompile) 
    {
        return process.cwd() + preCompiler._targetFolder + fileToCompile.replace(/\//g,'_')
                                                                        .replace(/\./g,'_') + '.txt';
    };
    
preCompiler.compileJadeFileToDisk = function(fileToCompile)
    {
        var fileToCompile_Path = process.cwd() + fileToCompile;
        
        if (fs.existsSync(fileToCompile_Path)===false)  {  return false;  }
    
        var targetFile_Path = preCompiler.calculateTargetPath(fileToCompile);
    
        if (fs.existsSync(targetFile_Path))             
        {  
            fs.unlinkSync(targetFile_Path);
        }
        var fileContents = fs.readFileSync(fileToCompile_Path,  "utf8");        
        var file_Compiled = jade.compileClient(fileContents , { filename:fileToCompile_Path, compileDebug : false} );
    
        var exportCode =  'var jade = require(\'jade/lib/runtime.js\'); \n' + 
                          'module.exports = ' + file_Compiled;
    
        
        fs.writeFileSync(targetFile_Path, exportCode);
        return fs.existsSync(targetFile_Path);            
    };

preCompiler.renderJadeFile = function(jadeFile, options)
    {
        //console.log(jadeFile);
        var targetFile_Path = preCompiler.calculateTargetPath(jadeFile);
        if (fs.existsSync(targetFile_Path) === false)
            if (preCompiler.compileJadeFileToDisk(jadeFile) === false)
            {
                return "";
            }
        return require(targetFile_Path)(options);
    };

/*var helpJadeFile = process.cwd() + '/source/html/help/index.jade';

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
        expect(loadedRequire()).to.be.an('string');*/

module.exports = preCompiler;