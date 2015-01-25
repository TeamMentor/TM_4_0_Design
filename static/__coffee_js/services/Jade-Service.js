/*jslint node: true */

var fs     = require('fs'),    
    path   = require('path'),
    jade   = require('jade'),
    Config = require('../Config');

var JadeService = function(config)
    {
        this.config       = config || new Config();
        this.targetFolder = this.config.jade_Compilation;            //path.join(this.config.cache_folder, '/node/_jade_PreCompiled/');               
        
        this.enableCache= function(value)                           //set to true to allow caching of jade compiled files
            {                
                if(value !== undefined) {     this.config.enable_Jade_Cache = value; }
                else                    {     this.config.enable_Jade_Cache = true;  }
                return this;
            };
        this.cacheEnabled = function()                           
            {
                return this.config.enable_Jade_Cache;
            };
        this.calculateTargetPath   = function(fileToCompile) 
            {
                return this.targetFolder + fileToCompile.replace(/\//g,'_')
                                                        .replace(/\./g,'_') + '.txt';
            };
            
        this.compileJadeFileToDisk = function(fileToCompile)
            {
                var fileToCompile_Path = path.join(process.cwd(), fileToCompile);


                if (fs.existsSync(fileToCompile_Path)===false)  {  return false;  }

                var targetFile_Path = this.calculateTargetPath(fileToCompile);

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
        
        this.renderJadeFile = function(jadeFile, params)
            {
                console.log("renderJadeFile : " + jadeFile)
                if (this.cacheEnabled() === false) 
                {
                    var jadeFile_Path = path.join(process.cwd(), jadeFile);
                    if (fs.existsSync(jadeFile_Path))
                    {            
                        return jade.renderFile(jadeFile_Path,params);
                    }
                    return "";
                }
                var targetFile_Path = this.calculateTargetPath(jadeFile);
                if (fs.existsSync(targetFile_Path) === false)
                {            
                    if (this.compileJadeFileToDisk(jadeFile) === false)
                    {
                        return "";
                    }
                }
                return require(targetFile_Path)(params);        
            };                        
        
        this.config.createCacheFolders();                   // ensure cache folders exists
    };

//var preCompiler = 
//    {
      //  _targetFolder : '/node/_jade_PreCompiled/',
      // disableCache  : true                        //set to false to allow caching of jade compiled files

  //  };

/*JadeService.prototype.cleanCacheFolder = function() 
    {
        var path = preCompiler.targetFolder();
        
        if( fs.existsSync(path) ) 
        {
            var count = 0; 
            
            var files = fs.readdirSync(path);
            files.forEach(function(fileName)
                {
                    var filePath = path  + fileName;
                    count ++;
                    fs.unlinkSync(filePath);
                });
            if (count) { console.log('[Removed ' + count + ' cache files]'); } 
        }
    };*/

/*JadeService.targetFolder = function()
    {
        var fullPath = process.cwd() + preCompiler._targetFolder ;
        if (fs.existsSync(fullPath) === false) 
        { 
            fs.mkdirSync(fullPath); 
        }
        return fullPath;
    };*/
                

    




//module.exports = preCompiler;
module.exports = JadeService;