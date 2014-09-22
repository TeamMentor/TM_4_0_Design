/*jslint node: true */
"use strict";

module.exports = function(grunt) 
{
  grunt.initConfig(
    {
        simplemocha : {  options: {  globals     : ['expect']      , timeout: 3000,
                                     ignoreLeaks :   false         , ui     : 'bdd',
                                     reporter    :  'list'         },
                         all    : {  src         : ['node/tests/**/**.js'] } },

        watch       : {  scripts: {  files       : ['node/**/**.js'],
                         tasks   :                 ['default']       ,
                         options : { spawn:          false }         , }, },                  
    });

    grunt.loadNpmTasks('grunt-contrib-watch');
    grunt.loadNpmTasks('grunt-simple-mocha' );
    
    grunt.registerTask('default', ['simplemocha']);
};