fs                 = require('fs')
path               = require('path')
cheerio            = require('cheerio')
expect             = require('chai').expect
app                = require('../../server')
Config             = require('../../misc/Config')
Library_Controller = require('../../controllers/Library-Controller')

describe 'controllers | Library-Controller.test.js |', ()->
    describe 'internal Functions.js |', ()->

        @timeout(15000)  # give 15 secs to start the TM 3.5 server

        it 'check ctor', ()->
            req = {};
            res = {};
            libraryController = new Library_Controller(req, res);

            expect(libraryController          ).to.be.an('Object');
            expect(libraryController.libraries).to.be.an('Object');
            expect(libraryController.req      ).to.deep.equal(req);
            expect(libraryController.res      ).to.deep.equal(res);
            expect(libraryController.config   ).to.deep.equal(new Config());

            expect(libraryController.jade_Service.config        ).to.be.an('Object');
            expect(libraryController.jade_Service.config.version).to.equal(new Config().version);

            customConfig = new Config();
            customVersion    = "aa.bb.cc";
            customConfig.version = customVersion;

            custom_libraryController = new Library_Controller(req, res, customConfig);
            expect(custom_libraryController.config                     ).to.equal(customConfig);
            expect(custom_libraryController.jade_Service.config        ).to.equal(customConfig);
            expect(custom_libraryController.jade_Service.config.version).to.equal(customVersion);

        it 'check default libraries mappings', ()->
            libraries = new Library_Controller().libraries;
            expect(libraries).to.be.an('Object')

            expect(libraries.Uno       ).to.be.an('Object')
            expect(libraries.Uno.id    ).to.be.an('String')
            expect(libraries.Uno.repo  ).to.be.an('String')
            expect(libraries.Uno.site  ).to.be.an('String')
            expect(libraries.Uno.title ).to.be.an('String')

            expect(libraries.Uno.name  ).to.equal('Uno' )
            expect(libraries.Uno.id    ).to.equal('be5273b1-d682-4361-99d9-6234f2d47eb7')
            expect(libraries.Uno.repo  ).to.equal('https://github.com/TMContent/Lib_UNO')
            expect(libraries.Uno.site  ).to.equal('https://tmdev01-uno.teammentor.net/')
            expect(libraries.Uno.title ).to.equal('Index')

            expect(libraries.ABC        ).to.not.be.an('Object')

        it 'mapLibraryData', (done)->
            library_Controller  = new Library_Controller();
            libraries           = library_Controller.libraries;

            library_Key  = "Uno";
            library_Name = "Guidance";
            library_ID   = 'be5273b1-d682-4361-99d9-6234f2d47eb7';
                
            library      = libraries[library_Key];
            expect(library).to.be.defined;

            libraries.Uno.data = null;

            library_Controller.mapLibraryData library, ()->
                expect(library.data).to.be.not.null
                data = library.data;

                expect(data).to.be.an('object')

                expect(data.name).to.be.an('String')
                expect(data.libraryId).to.be.an('String')
                expect(data.guidanceItems).to.be.an('Array')

                expect(data.name     ).to.equal(library_Name);
                expect(data.libraryId).to.equal(library_ID);

                library_Controller.mapLibraryData library, ()->
                    expect(library.data).to.deep.equal(data)
                    done();

        it 'mapLibraryData (using cache', (done)->
            library_Controller  = new Library_Controller();
            libraryData = { some : 'data'};
            library     = { id : 'abc123' , data: libraryData};
            cacheFile   = library_Controller.cacheLibraryData(library);
            expect(fs.existsSync(cacheFile)).to.be.true;

            library.data    = null;                                             # reset it so that we can confirm it was set

            library_Controller.mapLibraryData library, ()->
                    fs.unlinkSync(cacheFile);
                    expect(fs.existsSync(cacheFile)).to.be.false;
                    done();

        it 'cachedLibraryData', ()->
            library_Controller  = new Library_Controller();
            expect(library_Controller.cachedLibraryData).to.be.an('Function');
            expect(library_Controller.cachedLibraryData()).to.equal(null);

            libraryId   =  'abc123'

            libraryJson = '{ "id" : "' + libraryId + '", "name" : "' + libraryId + '"}'

            library        = { id : libraryId };
            cacheFile      = library_Controller.cachedLibraryData_File(library);

            fs.writeFileSync(cacheFile, libraryJson);
            expect(fs.existsSync(cacheFile)).to.be.true;

            libraryData = library_Controller.cachedLibraryData(library);
            expect(libraryData).to.be.an('Object');
            expect(libraryData.id   ).to.equal    (libraryId);
            expect(libraryData.name ).to.equal    (libraryId);
            expect(libraryData.abc  ).to.not.equal(libraryId);
            fs.unlinkSync(cacheFile);
            expect(fs.existsSync(cacheFile)).to.be.false;

        it 'cacheLibraryData', ()->
            library_Controller  = new Library_Controller();
            expect(library_Controller.cacheLibraryData).to.be.an('Function');
            expect(library_Controller.cacheLibraryData()).to.equal(null);

            library     = { id : 'abc123' };
            cacheFile   = library_Controller.cachedLibraryData_File(library);

            expect(library_Controller.cacheLibraryData(library)).to.equal(cacheFile);

            fileContents = fs.readFileSync(cacheFile, 'utf8');
            expect(fileContents).to.equal(JSON.stringify(library));
            expect(JSON.parse(fileContents)).to.deep.equal(library);

            fs.unlinkSync(cacheFile);
            expect(fs.existsSync(cacheFile)).to.be.false;
            
        it 'cachedLibraryData_Path', ()->
            libraryId   =  'abc123';
            library_Controller  = new Library_Controller();
            library        = { id : libraryId };
            expectedPath   = path.join(library_Controller.config.library_Data, libraryId + ".json");

            expect(library_Controller.cachedLibraryData_File(null)).to.equal(null);
            expect(library_Controller.cachedLibraryData_File(library)).to.equal(expectedPath)

        #it 'showLibraries',(done)->
        #    send = (html)->
        #        $ = cheerio.load(html)
        #        $('title').html().assert_Is('TEAM Mentor 4.0 (Html version)')
        #        $('#link-my-articles').attr().assert_Is( { id: 'link-my-articles', href: '/library/Uno' });
        #        done()
        #    req = {};
        #    res = { send: send }
#
        #    libraryController = new Library_Controller(req, res);
        #    libraryController.showLibraries()
#
        #it 'showLibrary (redirect)',(done)->
        #    redirect = (target)->
        #        target.assert_Is('/Libraries')
        #        done()
        #    req = {};
        #    res = { redirect: redirect }
#
        #    libraryController = new Library_Controller(req, res);
        #    libraryController.showLibrary()
#
        #it 'showLibrary (with name)',(done)->
        #    send = (html)->
        #        $ = cheerio.load(html)
        #        $('title').html().assert_Is('TEAM Mentor 4.0 (Html version)')
        #        $('#link-my-articles').attr().assert_Is( { id: 'link-my-articles', href: '/library/Uno' });
        #        html.assert_Contains('<a href="/graph/Administrative Controls">Administrative Controls</a>')
        #        done()
        #    req = { params: { name: 'Uno'}}
        #    res = { send: send }
#
        #    libraryController = new Library_Controller(req, res);
        #    libraryController.showLibrary()

        #it 'showQueries',(done)->
#
        #    send = (html)->
        #        $ = cheerio.load(html)
        #        $('title').html().assert_Is('TEAM Mentor 4.0 (Html version)')
        #        $('#link-my-articles').attr().assert_Is( { id: 'link-my-articles', href: '/library/Uno' });
        #        #html.assert_Contains('<a href="/graph/Administrative Controls">Administrative Controls</a>')
        #        #html.assert_Contains('<a href="/graph/Separate XML Data from Markup">Separate XML Data from Markup</a>')
        #        done()
#
        #    req = {}
        #    res = { send: send }
#
        #    libraryController = new Library_Controller(req, res);
        #    libraryController.showQueries()

     #  it.only 'showFolder',(done)->

     #      send = (html)->
     #          $ = cheerio.load(html)
     #          console.log html
     #          #$('title').html().assert_Is('TEAM Mentor 4.0 (Html version)')
     #          #$('#link-my-articles').attr().assert_Is( { id: 'link-my-articles', href: '/library/Uno' });
     #          #html.assert_Contains('<a href="/graph/Administrative Controls">Administrative Controls</a>')
     #          #html.assert_Contains('<a href="/graph/Separate XML Data from Markup">Separate XML Data from Markup</a>')
     #          done()

     #      req =  { params: { library: 'Uno', folder:'Logging'}}
     #      res = { send: send }

     #      libraryController = new Library_Controller(req, res);
     #      libraryController.showFolder()

