class Flare_API
  constructor  : (page    )-> @page = page
  clear_Session: (callback)-> @page.chrome.delete_Cookie 'connect.sid', 'http://localhost/', callback

  page_All            : (callback) => @page.open '/flare/all'                              , callback
  page_Home           : (callback) => @page.open '/'                                       , callback

module.exports = Flare_API