class Jade_API
  constructor: (page)->
    @page = page

  login        : (username, password, callback)=>
                  @page_Login =>
                    code = "document.querySelector('#new-user-username').value='#{username}';
                            document.querySelector('#new-user-password').value='#{password}';
                            document.querySelector('#btn-login').click()"
                    @page.chrome.eval_Script code, =>
                      @page.wait_For_Complete callback

  page_About    : (callback)=> @page.open '/landing-pages/about.html'            , callback
  page_Help     : (callback)=> @page.open '/help/index.html'                     , callback
  page_Home     : (callback)=> @page.open '/'                                    , callback
  page_Features : (callback)=> @page.open '/landing-pages/features.html'         , callback
  page_Login    : (callback)=> @page.open '/user/login/returning-user-login.html', callback
  page_Libraries: (callback)=> @page.open '/libraries'                           , callback

module.exports = Jade_API