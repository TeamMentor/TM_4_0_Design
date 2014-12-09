QA_TM_Design = require '../API/QA-TM_4_0_Design'

# this test suite contains all  all pages that we currently need to support for anonymous users (i.e. non logged in users)

describe 'all pages | anonymous users', ->
  page = QA_TM_Design.create();
  before (done)-> page.before done
  #after  (done)-> page.after done

  #afterEach (done)->
  #  testTitle = @.currentTest.fullTitle()
  #  page.screenshot testTitle, done

  afterEach (done)->
    page.html (html,$)->
      $('title').text().assert_Is('TEAM Mentor 4.0 (Html version)')           # confirm that all pages have the same title
                                                                              # confirm that all anonymous pages have the same top level menu
      navBarLinks = $('.nav li a')                                            # get all top right links using a css selector
      navBarLinks.length.assert_Is(6)                                         # there should be 6 links
      linksData = for link in navBarLinks                                     # for each link in navBarLinks
                    {                                                         # create a new object
                      href : link.attribs.href,                               # with the href
                      value: $(link).html()                                   # and the value (which is the innerHTML)
                    }                                                         # in coffee-script the last value is the default return value

      checkValues = (index, expected_Href,expected_Value ) ->                 # create a helper function to check for expected values
        linksData[index].href.assert_Is(expected_Href)
        linksData[index].value.assert_Is(expected_Value)

      checkValues(0,'/deploy/html/landing-pages/about.html'   , 'About'   )   # check expected values of 6 links
      checkValues(1,'/deploy/html/landing-pages/features.html', 'Features')
      checkValues(2,'/help/index.html'                        , 'Help')
      checkValues(3,'#'                                       , '|')
      checkValues(4,'/deploy/html/getting-started/index.html' , 'Sign Up')
      checkValues(5,'/deploy/html/getting-started/index.html' , 'Login')
      done()

  it.only '/',(done)->
    page.open '/', (html,$)->
      $('#usp h1').html().assert_Is('Instant resources that bridge the gap between developer questions and technical solutions')

      $('#usp a'     ).get(0).attribs.href       .assert_Is('../getting-started/index.html')
      $('#usp button').html()                    .assert_Is('Start your free trial today')
      $('#reasons h2').html()                    .assert_Is('With TEAM Mentor, you can...')
      $('#reasons h4')[0].children[0].data       .assert_Is('FIX vulnerabilities quicker than ever before with TEAM Mentor\'s seamless integration into a developer\'s IDE and daily workflow')
      $('#reasons h4')[1].children[0].data       .assert_Is('REDUCE the number of vulnerabilities over time as developers learn about each vulnerability at the time it is identified')
      $('#reasons h4')[2].children[0].data       .assert_Is('EXPAND the development team\'s knowledge and improve process with instant access to thousands of specific remediation tactics, including the host organization\'s security policies and coding best practices')

      $('#clients h2').html()                    .assert_Is('Our clients love us (and we think you will too!)')
      clientImages = $('#clients img')

      clientImages[0].attribs.src                .assert_Is('/deploy/assets/clients/elsevier.png'  )
      clientImages[1].attribs.src                .assert_Is('/deploy/assets/clients/fedex.png'     )
      clientImages[2].attribs.src                .assert_Is('/deploy/assets/clients/massmutual.png')
      clientImages[3].attribs.src                .assert_Is('/deploy/assets/clients/microsoft.png' )
      clientImages[4].attribs.src                .assert_Is('/deploy/assets/clients/symantec.png'  )
      clientImages[5].attribs.src                .assert_Is('/deploy/assets/clients/ubs.png'       )

      $('#call-to-action h1').html()             .assert_Is('Security Risk. Understood.'   )
      $('#call-to-action a' ).get(0).attribs.href.assert_Is('getting-started.html'          ) # BUG this is a broken link!

      $('#footer img'       ).get(0).attribs.src .assert_Is('/deploy/assets/logos/si-logo.png')
      $('#footer a'         ).html()             .assert_Is('Terms &amp; Conditions'          )
      done()

  it '/landing-pages/about.html',(done)->
    page.open '/landing-pages/about.html', (html,$)->
      done()

  it '/help/index.html',(done)->
    page.open '/help/index.html', (html,$)->
      done()





  describe 'misc other page tests', ->
    it 'page on root should have the same as /landing-pages/index.html', (done)->
      page.open '/', (html_1,$)->
        page.open '/landing-pages/index.html', (html_2)->
          html_1.assert_Is(html_2)
          done()





  #not stable (page load event not firing)
  #it '/aaaaaa (bad page',(done)->
  #  bad_Page = '/aaaaaa/asd'
  #  page.open '/aaaaaa', (html,$)->
  #      $('title').text().assert_Is('')
  #      $('body').html().assert_Is('Cannot GET /aaaaaa\n')
  #      done()