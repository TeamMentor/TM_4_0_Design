# Create a new configuration function that Grunt can
# consume.
module.exports = (grunt) ->

    cacheFolder  = "./.tmCache"
    filesToWatch = ['./node/**/**.*','source/**/**.*','./**/*.coffee' ]
    testsToRun   = 'node/tests/**/*Search*.*' #'node/tests/**/*jade*.js'
    reportMode   = 'dot'
    
    @initConfig
        clean:
            clean: cacheFolder
            
        watch:
            scripts:
                files    : filesToWatch
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