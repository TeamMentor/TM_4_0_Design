require 'fluentnode'
sass = require('node-sass');

class SCSS_Compiler

  compile: (scss, callback)=>
    if not scss
      callback(null)
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

  compile_File: (scss, callback)=>


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