# Create a new configuration function that Grunt can
# consume.
module.exports = (grunt) ->

    filesToWatch = 'node/**/**.js'
    testsToRun   = 'node/tests/**/*jade*.js'
    reportMode   = 'list'
    
    @initConfig
        watch:
            scripts:
                files    : [filesToWatch, "Gruntfile.coffee" ]
                tasks    : ["default"]
                options  :
                    spawn: false
        #mocha: null

    @registerTask 'mocha', 'Execute mochaJS tests....', ->
        
        done = @async()
        grunt.util.spawn
            cmd: "mocha"
            args: [testsToRun,"-R",reportMode], (error, result, code) ->
                if error
                    grunt.log.write error
                    done()
                else
                    grunt.log.write result
                    done()

    @registerTask "TM", "TM test Grunt task", ->
        grunt.log.writeln 'Starting TM 4 design compilation.'
        return true
        
    @loadNpmTasks('grunt-contrib-watch')
    
    @registerTask "default", ["TM", "mocha"]
    @registerTask "run", ["default", "watch"]