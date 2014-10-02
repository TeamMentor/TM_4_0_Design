GitHubApi = require('github')

class GitHubService
    constructor: ->
        @key     = "c2012dff24635c968afc"
        @secret  = "8e00a142cfc1ad59a22a4511c082476583cfb3da"
        @version = "3.0.0"
        @debug   = false
        @github  = null
        
        @authenticate()
    
    authenticate: ->
        @github = new GitHubApi (version: @version, debug: @debug)
        @github.authenticate    (type   : "oauth" , key  : @key, secret : @secret)
        return @

    rateLimit: (callback)->
        @github.misc.rateLimit {}, (err,res)->
            throw err if err
            callback(res)
        
    gist_Raw: (id, callback)->
        @github.gists.get  id : id, (err, res)->
            throw err if err
            callback(res)
            
    gist: (id, file, callback)->
        @github.gists.get  id : id, (err, res)->
            throw err if err
            if (file in Object.keys(res.files))
                callback(res.files[file].content)
            else
                callback(null)
                
    repo_Raw: (user,repo, callback)->
        @github.repos.get  user : user, repo: repo, (err, res)->
            throw err if err
            callback(res)
            
    tree_Raw: (user,repo, sha, callback)->
        recursive = true
        @github.gitdata.getTree  user : user, repo: repo, sha: sha, recursive : recursive, (err, res)->
            throw err if err
            callback(res)
    
    file: (user,repo, path, callback)->
        recursive = true
        @github.repos.getContent  user : user, repo: repo, path: path, (err, res)->
            throw err if err
            asciiContent = new Buffer(res.content, 'base64').toString('ascii')
            callback(asciiContent)
    
module.exports = GitHubService