# Create a new configuration function that Grunt can
# consume.
module.exports = (grunt) ->

    cacheFolder  = "./.tmCache"
    filesToWatch = 'node/**/**.js'
    testsToRun   = 'node/tests/**/**.*' #'node/tests/**/*jade*.js'
    reportMode   = 'list'
    
    @initConfig
        clean:
            clean: cacheFolder
            
        watch:
            scripts:
                files    : [filesToWatch, "./**/*.coffee" ]
                tasks    : ["default"]
                options  :
                    spawn: false
                    
        #mocha: null

    @registerTask 'mocha', 'Execute mochaJS tests....', ->
        done  = @async()
        params =
            cmd: "mocha"
            args: [testsToRun,"-R", reportMode, "--compilers", "coffee:coffee-script/register"]
        
        child = grunt.util.spawn params, (error, result, code) -> done()
                    
        child.stdout.pipe(process.stdout)
        child.stderr.pipe(process.stderr)
        
    @loadNpmTasks('grunt-contrib-clean')
    @loadNpmTasks('grunt-contrib-watch')
    
    
    @registerTask "default", ["mocha"]
    @registerTask "run"    , ["clean", "default", "default", "watch"]
    @registerTask "test"   , ["mocha"]