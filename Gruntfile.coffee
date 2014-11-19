# Create a new configuration function that Grunt can
# consume.
module.exports = (grunt) ->

    cacheFolder  = "./.tmCache"
    filesToWatch = ['./node/**/**.*','source/**/**.*','./**/*.coffee' ]
    testsToRun   = 'node/tests/**/*Graph*.*' #'node/tests/**/*jade*.js'
    reportMode   = 'list'
    
    currentBranch = 'Issue_68_Library_Rendering'
    
    @initConfig
        clean:
            clean: cacheFolder
            
        watch:
            scripts:
                files    : filesToWatch
                tasks    : ["default"]
                options  :
                    spawn: false
        githooks:
            all:
                "post-commit": "azure"
                    
        #mocha: null
    
    runCommand = (done, cmd, args) ->
        params = { cmd: cmd,  args: args }
        child  = grunt.util.spawn params, (error, result, code) -> done()
        child.stdout.pipe(process.stdout)
        child.stderr.pipe(process.stderr)
    
    @registerTask 'mocha', 'Execute mochaJS tests', ->
        cmd   = "mocha"
        args  = [testsToRun,"-R", reportMode, "--compilers", "coffee:coffee-script/register"]
        runCommand(@async(), cmd, args)
    
    @registerTask 'azure', 'Publish branch to azure', ->
        runCommand(@async(), 'git', ['push', 'azure', currentBranch + ':master'])
    
    @registerTask 'coverage', 'Run code coverage', ->
        runCommand(@async(), 'npm', ['run-script','coverage'])
    
    @loadNpmTasks('grunt-contrib-clean')
    @loadNpmTasks('grunt-contrib-watch')
    @loadNpmTasks('grunt-githooks')
    
    
    @registerTask "default", ["mocha"]
    @registerTask "run"    , ["clean", "default", "default", "watch"]
    @registerTask "test"   , ["mocha"]
    