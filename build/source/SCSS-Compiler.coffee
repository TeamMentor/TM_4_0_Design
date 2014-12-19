require 'fluentnode'
sass  = require('node-sass');
async = require('async')

class SCSS_Compiler

  compile: (scss, callback)=>
    if not scss
      callback '[SCSS_Compiler][compile] provided value was null)', null, null
    else
      stats= {}
      options =
        data       : scss,
        outputStyle: 'compressed',

        success    : (css  )-> callback(null , css , stats)
        error      : (error)-> callback(error, null, stats)
        stats      : stats
      sass.render options
      @

  compile_File: (file, callback)=>
    if not file or not file.file_Exists()
      callback '[SCSS_Compiler][compile_File] provided file was null or didn\'t exit)', null, null
    else
      stats= {}
      options =
        file       : file,
        outputStyle: 'compressed',
        success    : (css  )-> callback(null , css , stats)
        error      : (error)-> callback(error, null, stats)
        stats      : stats
      sass.render options
      @

  compile_File_To: (file,target, callback)=>
    if not file or not file.file_Exists() or not target
      callback '[SCSS_Compiler][compile_File_To] provided file was null or not available', null, null
    else
      target_File = if target and target.is_Folder() then target.path_Combine(file.file_Name_Without_Extension()).append('.css') else target
      @compile_File file, (error,css,stats) ->
        if error
          console.log error
          callback(error, null, stats)
        else
          css.saveAs(target_File)
          callback null, target_File, stats

  compile_Files_To: (files, target,callback)=>
    async.each files, ((file,next)=> @compile_File_To(file,target,()->next())), callback

module.exports = SCSS_Compiler

###
  var stats = {};
sass.render({
    data: 'body{background:blue; a{color:black;}}',
    success: function(css) {
        console.log(css);
        console.log(stats);
    },
    error: function(error) {
        console.log(error);
    },
    includePaths: [ 'lib/', 'mod/' ],
    outputStyle: 'compressed',
    stats: stats
});
###