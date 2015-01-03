QA_TM_Design = require '../API/QA-TM_4_0_Design'

# this test suite contains all  all pages that we currently need to support for anonymous users (i.e. non logged in users)
describe 'jade-anonymous-users', ->
  page = QA_TM_Design.create(before, after);
  jade = page.jade_API;

  #afterEach (done)->
  #  testTitle = @.currentTest.fullTitle()
  #  page.screenshot testTitle, done

  before (done)-> jade.clear_Session done                                   # ensure we are anonymous

  @timeout(4000)

  afterEach (done)->
    page.html (html,$)->
      $('title').text().assert_Is('TEAM Mentor 4.0 (Html version)')         # confirm that all pages have the same title
      check_Top_Right_Navigation_Bar($)
      done()

  check_Top_Right_Navigation_Bar = ($)->                                    # confirm that all anonymous pages have the same top level menu
    navBarLinks = $('#links li a')                                            # get all top right links using a css selector
    navBarLinks.length.assert_Is(5)                                         # there should be 6 links
    linksData = for link in navBarLinks                                     # for each link in navBarLinks
      {                                                                     # create a new object
        href : link.attribs.href,                                           # with the href
        value: $(link).html()                                               # and the value (which is the innerHTML)
      }                                                                     # in coffee-script the last value is the default return value

    checkValues = (index, expected_Href,expected_Value ) ->                 # create a helper function to check for expected values
      linksData[index].href.assert_Is(expected_Href)
      linksData[index].value.assert_Is(expected_Value)

    checkValues(0,'/guest/about.html'    , 'About'   )   # check expected values of 6 links
    checkValues(1,'/guest/features.html' , 'Features')
    checkValues(2,'/help/index.html'     , 'Help'    )
    checkValues(3,'/guest/sign-up.html'  , 'Sign Up' )
    checkValues(4,'/guest/login.html'    , 'Login'   )

  check_Generic_Footer = ($)->
    $('#call-to-action h1'      ).html()             .assert_Is('Security Risk. Understood.'           )
    $('#call-to-action a'       ).get(0).attribs.href.assert_Is('/guest/sign-up.html'                  ) # BUG this is a broken link!
    $('#call-to-action button'  ).text()             .assert_Is('See for yourself'                     )
    $('#call-to-action button i').attr()             .assert_Is({ class: 'fi-eye' })

    $('#footer #footer-img h6'        ).html().assert_Contains('TEAM Mentor v')

  extract_Style_Data = (styleCss)->
    items = {}
    for item in styleCss.split(';')
      if (item)
        items[item.split(':').first().trim()] =item.split(':').second().trim()
    return items

  check_Generic_Footer_Css = (html, baseUrl, next)->
    juice   = require('juice')
    cheerio = require('cheerio')
    juice.juiceContent html, { url: baseUrl}, (err, cssHtml)->
      $css = cheerio.load(cssHtml)
      footer_Attr = $css('#footer #footer-img #si-logo').attr()
      footer_Attr.assert_Is {  id: 'si-logo'
                             , style: 'background: url(../assets/logos/logos.jpg) no-repeat; background-position: 0px -50px; height: 50px; width: 250px; margin: 0 auto;' }

      items = extract_Style_Data(footer_Attr.style)

      items['background'].assert_Is('url(../assets/logos/logos.jpg) no-repeat' )
      next()

  it '/',(done)->
    jade.page_Home (html,$)->
      $('#usp h2').html().assert_Is('Instant resources that bridge the gap between developer questions and technical solutions')

      $('#usp a'       ).get(0).attribs.href       .assert_Is('/guest/sign-up.html')
      $('#usp button'  ).text()                    .assert_Is('Start your free trial today')
      $('#usp button i').attr()                  .assert_Is({ class: 'fi-key' })
      $('#reasons h2'  ).html()                    .assert_Is('With TEAM Mentor, you can')

      $($('#reasons h4 p').get(0)).html()       .assert_Is('FIX vulnerabilities quicker than ever before with TEAM Mentor&apos;s seamless integration into a developer&apos;s IDE and daily workflow.')
      $($('#reasons h4 p').get(1)).html()       .assert_Is('REDUCE the number of vulnerabilities over time as developers learn about each vulnerability at the time it is identified.')
      $($('#reasons h4 p').get(2)).html()       .assert_Is('EXPAND the development team&apos;s knowledge and improve process with access to thousands of specific remediation tactics, including the host organization&apos;s security policies and coding best practices.')

      $('#clients h2').html()                    .assert_Is('Our clients love us (and we think you will too!)')
      clientImages = $('#clients img')

      clientImages[0].attribs.src                .assert_Is('/static/assets/clients/elsevier.jpg'  )
      clientImages[1].attribs.src                .assert_Is('/static/assets/clients/fedex.jpg'     )
      clientImages[2].attribs.src                .assert_Is('/static/assets/clients/massmutual.jpg')
      clientImages[3].attribs.src                .assert_Is('/static/assets/clients/microsoft.jpg' )
      clientImages[4].attribs.src                .assert_Is('/static/assets/clients/symantec.jpg'  )
      clientImages[5].attribs.src                .assert_Is('/static/assets/clients/ubs.jpg'       )

      check_Generic_Footer($)
      check_Generic_Footer_Css($.html(), 'http://localhost:1337/', done)

  it 'About',(done)->
    jade.page_About (html,$)->
      $(  '#about h2'   ).html()        .assert_Is('An interactive Application Security library with thousands of code samples and professional guidance when you need it')
      $(  '#about-us h4').html()        .assert_Is('TEAM Mentor was created by developers for developers using secure coding standards, code snippets and checklists built from 10+ years of targeted security assessments for Fortune 500 organizations.')
      $($('#about-us p' ).get(0)).html().assert_Is('It contains over 4,000 articles with dynamic content across multiple development platforms including .NET, Java, C/C++, PHP, Android and iOS. TEAM Mentor is the In-Practice companion to our TEAM Professor eLearning courses, extending developers&#x2019; knowledge in combination with training.')
      $($('#about-us p' ).get(1)).html().assert_Is('TeamMentor integrates with static analysis tools, such as Checkmarx and Fortify, helping teams make more sense of scan results and make critical decisions to fix software vulnerabilities.')

      check_Generic_Footer($);
      done()

  it  'Features',(done)->
    jade.page_Features (html,$)->
      $(  '#features h4'   ).html()        .assert_Is('Delivers compliance-specific secure coding guidance for PCI-DSS, OWASP Top 10, CWE and other popular frameworks.')
      $($('.row h4').get(0)).html()        .assert_Is('Delivers compliance-specific secure coding guidance for PCI-DSS, OWASP Top 10, CWE and other popular frameworks.')
      $($('.row h4').get(1)).html()        .assert_Is('Integrates with multiple static analysis tools and developer environments (IDE&#x2019;s) to map prescriptive coding guidance to scan results to fix vulnerabilities.')
      $($('.row h4').get(2)).html()        .assert_Is('Stores and cross-references your security policies with out-of-the-box secure coding checklists and examples.')
      $($('.row h4').get(3)).html()        .assert_Is('Provides guidance to assist developers in reducing security vulnerabilities in software applications.')

      check_Generic_Footer($)
      done()


  it 'Help',(done)->
    jade.page_Help (html,$)->
      titles = ($(h4).text() for h4 in $('#help-nav h4'))
      titles.assert_Is ["About TEAM Mentor", "Installation", "Administration", "UI Elements",
                        "Reading Content","Editing Content","Eclipse for Fortify plugin",
                        "HP Fortify SCA UI Integration","Visual Studio Plugin"]

      $(  '#help-docs h2').html().assert_Is('TEAM Mentor Documents')
      $($('#help-docs p' ).get(0)).html().assert_Is('Welcome to the TEAM Mentor Documentation Website where you will find detailed information on \nhow to install TEAM Mentor, how it works and how to customize it.')
      $($('#help-docs h4').get(0)).html().assert_Is('TEAM Mentor in action:')
      #todo: add check for links
      $($('#help-docs p' ).get(1)).html().assert_Is('Other places to get information about TeamMentor:')
      $($('#help-docs h4').get(1)).html().assert_Is('TEAM Mentor Related Sites')
      #todo: add check for links

      done()

  it 'Login', (done)->
    jade.page_Login (html,$)->
      $('h3').html().assert_Is("Login")
      $('p' ).html().assert_Is("Returning customer? Please log in to access TEAM Mentor.")
      $.html('#new-user-username').assert_Contains('name="username"')
      $.html('#new-user-password').assert_Contains('name="password"')
      $('#btn-login').html().assert_Is('Login')
      $('#btn-forgot-pwd').html().assert_Is('Forgot your password?')
      $('#btn-login'     ).attr('type').assert_Is('submit')
      $('#btn-forgot-pwd').attr('type').assert_Is('button')
      $('#btn-forgot-pwd').parent().attr('href').assert_Is('/guest/pwd-forgot.html')
      done()

  it 'Login Fail', (done)->
    jade.page_Login_Fail (html, $)->
      $('.alert').html().assert_Is('Login failed, please try again :(')
      $('h3').html().assert_Is("Login")
      $('p' ).html().assert_Is("Returning customer? Please log in to access TEAM Mentor.")
      # Same as "it 'Login', (done)->" , so we should also check if those fields are here
      done()

  it "Login Required", (done)->
    jade.page_Login_Required (html,$)->
      page.chrome.url (url)->
        $('#loginwall .alert').html('You need to login to see that page :)')
        $('#loginwall h3').html().assert_Is("Login")
        $('#loginwall p').text().assert_Is('Returning customer? Please log in to access TEAM Mentor.')
        done()

  it 'Password Forgot', (done)->
    jade.page_Pwd_Forgot (html, $)->
      $('h3').html().assert_Is("Forgot your password?")
      $('p' ).html().assert_Is("Too easy - just type in your email address and we&apos;ll send you an email with further instructions.")
      $.html('.form-group label') .assert_Is('<label for="email">Email Address</label>')
      $.html('#email').assert_Is('<input id="email" type="email" name="email" placeholder="Email Address" class="form-control">')
      $('#forgot-password').attr('action').assert_Is('/user/pwd_reset')
      $('button').html().assert_Is('Get password')
      done()

  it 'Password Sent', (done)->
    jade.page_Pwd_Sent (html,$)->
      $('h3').html().assert_Is("Login")
      $('#loginwall .alert' ).html().assert_Is("We&apos;ve sent you an email with instructions for resetting your password :)")
      done()

  it 'Sign Up', (done) ->
    jade.page_Sign_Up (html,$)->
      $('h3'                                  ).html().assert_Is("Sign Up")
      $('p'                                   ).html().assert_Is("Create an account and get access to the world&apos;s largest repository of secure software development knowledge.")

      $('form'                                ).attr().assert_Is({ id: 'sign-up-form', role: 'form' , method:'POST', action: '/user/sign-up' })
      $('label[for=new-user-username]'        ).html().assert_Is('Username')
      $('label[for=new-user-password]'        ).html().assert_Is('Password')
      $('label[for=new-user-confirm-password]').html().assert_Is('Confirm Password')
      $('label[for=new-user-email]'           ).html().assert_Is('Email Address')

      $('input[id=new-user-username]'         ).attr().assert_Is({ id: 'new-user-username'        , name: 'username'        , type: 'text'    , placeholder: 'Username'        , class: 'form-control' })
      $('input[id=new-user-password]'         ).attr().assert_Is({ id: 'new-user-password'        , name: 'password'        , type: 'password', placeholder: 'Password'        , class: 'form-control' })
      $('input[id=new-user-confirm-password]' ).attr().assert_Is({ id: 'new-user-confirm-password', name: 'password-confirm', type: 'password', placeholder: 'Confirm Password', class: 'form-control' })
      $('input[id=new-user-email]'            ).attr().assert_Is({ id: 'new-user-email'           , name: 'email'           , type: 'email'   , placeholder: 'Email Address'   , class: 'form-control' })
      $('button#btn-sign-up'                  ).html().assert_Is('Sign Up')
      $('button#btn-sign-up'                  ).attr().assert_Is({ id:'btn-sign-up', type:'submit'})
      done()

  it 'Sign Up Fail', (done) ->
    jade.page_Sign_Up_Fail (html,$)->
      $('.alert').html().assert_Is('Sign Up failed, please try again :(')
      $('h3'    ).html().assert_Is("Sign Up")
      done()

  it  'Sign Up OK', (done) ->
    jade.page_Sign_Up_OK (html,$)->
      $('h3' )      .html().assert_Is('Login'                     )
      $('#loginwall .alert').html().assert_Is('Thanks for signing up to TEAM Mentor. Please login to access our libraries :)')
      $('#loginwall h3').html().assert_Is("Login")
      $('#loginwall p').text().assert_Is('Returning customer? Please log in to access TEAM Mentor.')
      done()

  it 'Tearms and Conditions', (done)->
    jade.page_TermsAndCond (html,$)->
      $('h3').html().assert_Is('Security Innovation Software License Agreement')
      done()




  #not stable (page load event not firing)
  #it '/aaaaaa (bad page',(done)->
  #  bad_Page = '/aaaaaa/asd'
  #  page.open '/aaaaaa', (html,$)->
  #      $('title').text().assert_Is('')
  #      $('body').html().assert_Is('Cannot GET /aaaaaa\n')
  #      done()
