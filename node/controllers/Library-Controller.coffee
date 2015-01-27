fs            = require('fs')
path          = require('path')
request       = require('request')
Config        = require('../misc/Config')
Jade_Service  = require('../services/Jade-Service')

libraries =
              "Uno"   :
                          name : 'Uno'
                          id   : 'be5273b1-d682-4361-99d9-6234f2d47eb7'
                          repo : 'https://github.com/TMContent/Lib_UNO'
                          site : new Config().tm_35_Server
                          title: 'Index'
                          data : null
              "html5" :
                          name : 'html5'
                          id   : '7d2d0571-e542-45cd-9335-d7a0556c2bea'
                          repo : 'https://github.com/TMContent/Lib_Html5'
                          site : new Config().tm_35_Server
                          title: 'Html 5'
                          data : null

            
            
class Library_Controller

  constructor: (req, res, config)->

    @.req          = req;
    @.res          = res;
    @.libraries    = libraries;
    @.config       = config || new Config();
    @.jade_Service = new Jade_Service(@.config);




  showLibraries: ()=>

    viewModel = {'libraries' : @.libraries};

    @.res.send @.jade_Service.renderJadeFile('/source/jade/user/list.jade', viewModel)

  showLibrary: ()=>
    name = if (@.req && @.req.params) then @.req.params.name else "";
    library = @.libraries[name];
    if(library)
        viewModel = {'libraries' : @.libraries , library : library};
        @.mapLibraryData library, ()=>
          @.res.send @.jade_Service.renderJadeFile('/source/jade/user/library.jade', viewModel)
    else
        @.res.redirect('/Libraries')


  #showQueries: ()=>
  #  server = 'http://localhost:1332';
  #  url    = '/graph-db/queries/'
  #  request(server + url, (error, response,data)=>
  #    viewModel= {}
#
  #    if(data && data !='')
  #      graph = JSON.parse(data)
  #      if (graph)
  #        nodes = graph.nodes;
  #        node_Labels = [];
  #        if (nodes)
  #          nodes.forEach (node)->
  #            node_Labels.push(node.label);
#
  #        viewModel = {'queries': node_Labels.sort()};
#
  #    @.res.send @.jade_Service.renderJadeFile('/source/jade/user/queries.jade', viewModel))



  mapLibraryData: (library, next)=>
    cachedLibrary = @.cachedLibraryData(library);
    if (cachedLibrary)
      library.data = cachedLibrary.data;

    if(library.data)
      next()
      return;

    url  = library.site + 'rest/library/' + library.id;

    request.get {url: url, json:true}, (error, request, body)=>
      throw error if(error)
      library.data = body;
      @.cacheLibraryData(library);
      next()


  cachedLibraryData: (library)=>
    if(library && library.id)
      cacheFile =  @.cachedLibraryData_File(library)
      if (fs.existsSync(cacheFile))
        fileContents = fs.readFileSync(cacheFile, 'utf8')
        if (fileContents)
          return JSON.parse(fileContents)

    return null

  cacheLibraryData: (library)=>

    if(library && library.id)
      cacheFile =  @.cachedLibraryData_File(library);
      fs.writeFileSync(cacheFile, JSON.stringify(library));
      return cacheFile

    return null

  cachedLibraryData_File: (library)=>
    if(library && library.id)
        return  path.join(@.config.library_Data, library.id + ".json");
    return null;



Express_Service  = require('../services/Express-Service')

Library_Controller.registerRoutes =  (app)=>
  check_Auth = (req,res,next)-> new Express_Service().checkAuth(req, res,next, app.config)
  app.get '/libraries'      , check_Auth, (req, res)=> new Library_Controller(req, res, app.config).showLibraries()
  #app.get '/library/queries', check_Auth, (req, res)=> new Library_Controller(req, res, app.config).showQueries()
  app.get '/library/:name'  , check_Auth, (req, res)=> new Library_Controller(req, res, app.config).showLibrary()

module.exports = Library_Controller


