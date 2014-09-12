/*jslint node: true */

var fs   = require('fs'),
    jade = require('jade');

var preCompiler = 
    {
        _targetFolder : '/node/_jade_PreCompiled/',
        disableCache  : true
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

preCompiler.renderJadeFile = function(jadeFile, params)
    {
        if (preCompiler.disableCache)
        {
            return jade.renderFile(process.cwd() + jadeFile,params);
        }
        //console.log(jadeFile);
        var targetFile_Path = preCompiler.calculateTargetPath(jadeFile);
        if (fs.existsSync(targetFile_Path) === false)
        {
            if (preCompiler.compileJadeFileToDisk(jadeFile) === false)
            {
                return "";
            }
        }
        return require(targetFile_Path)(params);        
    };

module.exports = preCompiler;