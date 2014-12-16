var jade = require('jade/lib/runtime.js'); 
module.exports = function template(locals) {
var buf = [];
var jade_mixins = {};
var jade_interp;
;var locals_for_with = (locals || {});(function (loggedIn, library, title, content) {
if ( (loggedIn)	)
{
buf.push("<!DOCTYPE html><html lang=\"en\">");
var head_title = 'TEAM Mentor 4.0 (Html version)'




























































buf.push("<head>  <meta charset=\"utf-8\"><meta http-equiv=\"X-UA-Compatible\" content=\"IE=edge\"><meta name=\"viewport\" content=\"width=device-width, initial-scale=1\"><meta name=\"description\" content=\"\"><meta name=\"author\" content=\"\"><link rel=\"icon\" sizes=\"57x57\" href=\"/static/assets/favicons/apple-touch-icon-57x57.png\"><link rel=\"icon\" sizes=\"114x114\" href=\"/static/assets/favicons/apple-touch-icon-114x114.png\"><link rel=\"icon\" sizes=\"72x72\" href=\"/static/assets/favicons/apple-touch-icon-72x72.png\"><link rel=\"icon\" sizes=\"144x144\" href=\"/static/assets/favicons/apple-touch-icon-144x144.png\"><link rel=\"icon\" sizes=\"60x60\" href=\"/static/assets/favicons/apple-touch-icon-60x60.png\"><link rel=\"icon\" sizes=\"120x120\" href=\"/static/assets/favicons/apple-touch-icon-120x120.png\"><link rel=\"icon\" sizes=\"76x76\" href=\"/static/assets/favicons/apple-touch-icon-76x76.png\"><link rel=\"icon\" sizes=\"152x152\" href=\"/static/assets/favicons/apple-touch-icon-152x152.png\"><link rel=\"icon\" type=\"image/png\" href=\"/static/assets/favicons/favicon-196x196.png\" sizes=\"196x196\"><link rel=\"icon\" type=\"image/png\" href=\"/static/assets/favicons/favicon-160x160.png\" sizes=\"160x160\"><link rel=\"icon\" type=\"image/png\" href=\"/static/assets/favicons/favicon-160x160.png\" sizes=\"160x160\"><link rel=\"icon\" type=\"image/png\" href=\"/static/assets/favicons/favicon-96x96.png\" sizes=\"96x96\"><link rel=\"icon\" type=\"image/png\" href=\"/static/assets/favicons/favicon-16x16.png\" sizes=\"16x16\"><link rel=\"icon\" type=\"image/png\" href=\"/static/assets/favicons/favicon-32x32.png\" sizes=\"32x32\"><link rel=\"icon\" sizes=\"114x114\" href=\"/static/assets/favicons/apple-touch-icon-114x114.png\"><link rel=\"icon\" sizes=\"114x114\" href=\"/static/assets/favicons/apple-touch-icon-114x114.png\"><link rel=\"icon\" sizes=\"114x114\" href=\"/static/assets/favicons/apple-touch-icon-114x114.png\"><title>" + (jade.escape((jade_interp = head_title) == null ? '' : jade_interp)) + "</title><!-- Normalize--><link href=\"/static/css/normalize.css\" rel=\"stylesheet\"><!-- Custom Styles--><link href=\"/static/css/custom-style.css\" rel=\"stylesheet\"><!--weird CSS fix to handle Chrome prob when <form> exists--><style>.pull-right { float  : right !important; }\n.navbar ul  { display: inline-block;     }</style></head><body>");
jade_mixins["image-teammentor-logo__default"] = function(){
var block = (this && this.block), attributes = (this && this.attributes) || {};
buf.push("<a href=\"/index.html\"><img src=\"/static/assets/logos/tm-logo.jpg\" alt=\"TEAM Mentor\" width=\"200px\"></a>");
};
var articles        = '/static/html/articles'
var getting_started = '/static/html/getting-started'
var home            = '/static/html/home'
var landing_pages   = '/static/html/landing-pages'
var help            = '/help'
var user            = '/user'
var link_article_new_window       = articles + '/article-new-window-view.html'
var link_app_keyword_search       = home     + '/app-keyword-search.html'
var link_fundamentals_of_security = articles + '/fundamentals-of-security.html'
jade_mixins["links-navbar__landing-page"] = function(){
var block = (this && this.block), attributes = (this && this.attributes) || {};
buf.push("<ul>\n<li><a href=\"/guest/about.html\">About</a></li>\n<li><a href=\"/guest/features.html\">Features</a></li>\n<li><a href=\"/help/index.html\">Help</a></li>\n<li><a href=\"#\">|</a></li>\n<li><a href=\"/guest/sign-up.html\">Sign Up</a></li>\n<li><a href=\"/guest/login.html\">Login</a></li>\n</ul>\n");
};
jade_mixins["links-navbar__home"] = function(){
var block = (this && this.block), attributes = (this && this.attributes) || {};
buf.push("<ul>\n<li><a href=\"/library/Uno\"><img src=\"/static/assets/icons/navigate.png\" alt=\"Navigate\"></a></li>\n<li><a href=\"/user/main.html\"><img src=\"/static/assets/icons/home.png\" alt=\"Home\"></a></li>\n<li><a href=\"/help/index.html\"><img src=\"/static/assets/icons/help.png\" alt=\"Help\"></a></li>\n<li><a href=\"/user/logout\"><img src=\"/static/assets/icons/logout.png\" alt=\"Logout\"></a></li>\n</ul>\n");
};
















buf.push("<div role=\"navigation\" class=\"navbar navbar-fixed-top\"><div class=\"lge-container\"><ul class=\"brand\"><li>");
jade_mixins["image-teammentor-logo__default"].call({
block: function(){
buf.push(" ");
}
});
buf.push("</li></ul><div class=\"pull-right\"><ul class=\"nav nav-icons\">");
jade_mixins["links-navbar__home"]();
buf.push("</ul></div></div></div><div id=\"application\"><div class=\"row\"><div id=\"help-nav\" class=\"column-3\"><div class=\"lge-container\"><div data-spay=\"affix\" data-offset-top=\"60\" data-offset-bottom=\"200\" class=\"div\">");
if ( library)
{
// iterate library.Views
;(function(){
  var $$obj = library.Views;
  if ('number' == typeof $$obj.length) {

    for (var $index = 0, $$l = $$obj.length; $index < $$l; $index++) {
      var view = $$obj[$index];

buf.push("<h4>" + (jade.escape(null == (jade_interp = view.Title) ? "" : jade_interp)) + "</h4><ul class=\"sidebar\">");
// iterate view.Articles
;(function(){
  var $$obj = view.Articles;
  if ('number' == typeof $$obj.length) {

    for (var $index = 0, $$l = $$obj.length; $index < $$l; $index++) {
      var article = $$obj[$index];

buf.push("<li><a" + (jade.attr("href", '/help/' + article.Id, true, true)) + ">" + (jade.escape(null == (jade_interp = article.Title) ? "" : jade_interp)) + "</a></li>");
    }

  } else {
    var $$l = 0;
    for (var $index in $$obj) {
      $$l++;      var article = $$obj[$index];

buf.push("<li><a" + (jade.attr("href", '/help/' + article.Id, true, true)) + ">" + (jade.escape(null == (jade_interp = article.Title) ? "" : jade_interp)) + "</a></li>");
    }

  }
}).call(this);

buf.push("</ul>");
    }

  } else {
    var $$l = 0;
    for (var $index in $$obj) {
      $$l++;      var view = $$obj[$index];

buf.push("<h4>" + (jade.escape(null == (jade_interp = view.Title) ? "" : jade_interp)) + "</h4><ul class=\"sidebar\">");
// iterate view.Articles
;(function(){
  var $$obj = view.Articles;
  if ('number' == typeof $$obj.length) {

    for (var $index = 0, $$l = $$obj.length; $index < $$l; $index++) {
      var article = $$obj[$index];

buf.push("<li><a" + (jade.attr("href", '/help/' + article.Id, true, true)) + ">" + (jade.escape(null == (jade_interp = article.Title) ? "" : jade_interp)) + "</a></li>");
    }

  } else {
    var $$l = 0;
    for (var $index in $$obj) {
      $$l++;      var article = $$obj[$index];

buf.push("<li><a" + (jade.attr("href", '/help/' + article.Id, true, true)) + ">" + (jade.escape(null == (jade_interp = article.Title) ? "" : jade_interp)) + "</a></li>");
    }

  }
}).call(this);

buf.push("</ul>");
    }

  }
}).call(this);

}
buf.push("</div></div></div><div id=\"help-docs\" class=\"column-6\"><div class=\"lge-container\">");
if ( title)
{
buf.push("<h2>" + (jade.escape(null == (jade_interp = title) ? "" : jade_interp)) + "</h2>");
}
buf.push((null == (jade_interp = content) ? "" : jade_interp) + "</div></div></div></div></body></html>");
}
else
{
buf.push("<!DOCTYPE html><html lang=\"en\">");
var head_title = 'TEAM Mentor 4.0 (Html version)'




























































buf.push("<head>  <meta charset=\"utf-8\"><meta http-equiv=\"X-UA-Compatible\" content=\"IE=edge\"><meta name=\"viewport\" content=\"width=device-width, initial-scale=1\"><meta name=\"description\" content=\"\"><meta name=\"author\" content=\"\"><link rel=\"icon\" sizes=\"57x57\" href=\"/static/assets/favicons/apple-touch-icon-57x57.png\"><link rel=\"icon\" sizes=\"114x114\" href=\"/static/assets/favicons/apple-touch-icon-114x114.png\"><link rel=\"icon\" sizes=\"72x72\" href=\"/static/assets/favicons/apple-touch-icon-72x72.png\"><link rel=\"icon\" sizes=\"144x144\" href=\"/static/assets/favicons/apple-touch-icon-144x144.png\"><link rel=\"icon\" sizes=\"60x60\" href=\"/static/assets/favicons/apple-touch-icon-60x60.png\"><link rel=\"icon\" sizes=\"120x120\" href=\"/static/assets/favicons/apple-touch-icon-120x120.png\"><link rel=\"icon\" sizes=\"76x76\" href=\"/static/assets/favicons/apple-touch-icon-76x76.png\"><link rel=\"icon\" sizes=\"152x152\" href=\"/static/assets/favicons/apple-touch-icon-152x152.png\"><link rel=\"icon\" type=\"image/png\" href=\"/static/assets/favicons/favicon-196x196.png\" sizes=\"196x196\"><link rel=\"icon\" type=\"image/png\" href=\"/static/assets/favicons/favicon-160x160.png\" sizes=\"160x160\"><link rel=\"icon\" type=\"image/png\" href=\"/static/assets/favicons/favicon-160x160.png\" sizes=\"160x160\"><link rel=\"icon\" type=\"image/png\" href=\"/static/assets/favicons/favicon-96x96.png\" sizes=\"96x96\"><link rel=\"icon\" type=\"image/png\" href=\"/static/assets/favicons/favicon-16x16.png\" sizes=\"16x16\"><link rel=\"icon\" type=\"image/png\" href=\"/static/assets/favicons/favicon-32x32.png\" sizes=\"32x32\"><link rel=\"icon\" sizes=\"114x114\" href=\"/static/assets/favicons/apple-touch-icon-114x114.png\"><link rel=\"icon\" sizes=\"114x114\" href=\"/static/assets/favicons/apple-touch-icon-114x114.png\"><link rel=\"icon\" sizes=\"114x114\" href=\"/static/assets/favicons/apple-touch-icon-114x114.png\"><title>" + (jade.escape((jade_interp = head_title) == null ? '' : jade_interp)) + "</title><!-- Normalize--><link href=\"/static/css/normalize.css\" rel=\"stylesheet\"><!-- Custom Styles--><link href=\"/static/css/custom-style.css\" rel=\"stylesheet\"><!--weird CSS fix to handle Chrome prob when <form> exists--><style>.pull-right { float  : right !important; }\n.navbar ul  { display: inline-block;     }</style></head><body>");
var articles        = '/static/html/articles'
var getting_started = '/static/html/getting-started'
var home            = '/static/html/home'
var landing_pages   = '/static/html/landing-pages'
var help            = '/help'
var user            = '/user'
var link_article_new_window       = articles + '/article-new-window-view.html'
var link_app_keyword_search       = home     + '/app-keyword-search.html'
var link_fundamentals_of_security = articles + '/fundamentals-of-security.html'
jade_mixins["links-navbar__landing-page"] = function(){
var block = (this && this.block), attributes = (this && this.attributes) || {};
buf.push("<ul>\n<li><a href=\"/guest/about.html\">About</a></li>\n<li><a href=\"/guest/features.html\">Features</a></li>\n<li><a href=\"/help/index.html\">Help</a></li>\n<li><a href=\"#\">|</a></li>\n<li><a href=\"/guest/sign-up.html\">Sign Up</a></li>\n<li><a href=\"/guest/login.html\">Login</a></li>\n</ul>\n");
};
jade_mixins["links-navbar__home"] = function(){
var block = (this && this.block), attributes = (this && this.attributes) || {};
buf.push("<ul>\n<li><a href=\"/library/Uno\"><img src=\"/static/assets/icons/navigate.png\" alt=\"Navigate\"></a></li>\n<li><a href=\"/user/main.html\"><img src=\"/static/assets/icons/home.png\" alt=\"Home\"></a></li>\n<li><a href=\"/help/index.html\"><img src=\"/static/assets/icons/help.png\" alt=\"Help\"></a></li>\n<li><a href=\"/user/logout\"><img src=\"/static/assets/icons/logout.png\" alt=\"Logout\"></a></li>\n</ul>\n");
};
















jade_mixins["image-teammentor-logo__default"] = function(){
var block = (this && this.block), attributes = (this && this.attributes) || {};
buf.push("<a href=\"/index.html\"><img src=\"/static/assets/logos/tm-logo.jpg\" alt=\"TEAM Mentor\" width=\"200px\"></a>");
};
buf.push("<div role=\"navigation\" class=\"navbar navbar-fixed-top\"><div class=\"lge-container\"><ul class=\"brand\"><li>");
jade_mixins["image-teammentor-logo__default"].call({
block: function(){
buf.push("    ");
}
});
buf.push("</li></ul><div class=\"collapse pull-right\"><ul class=\"nav nav-text\">");
jade_mixins["links-navbar__landing-page"]();
buf.push("</ul></div></div></div><div id=\"application\"><div class=\"row\"><div id=\"help-nav\" class=\"column-3\"><div class=\"lge-container\"><div data-spay=\"affix\" data-offset-top=\"60\" data-offset-bottom=\"200\" class=\"div\">");
if ( library)
{
// iterate library.Views
;(function(){
  var $$obj = library.Views;
  if ('number' == typeof $$obj.length) {

    for (var $index = 0, $$l = $$obj.length; $index < $$l; $index++) {
      var view = $$obj[$index];

buf.push("<h4>" + (jade.escape(null == (jade_interp = view.Title) ? "" : jade_interp)) + "</h4><ul class=\"sidebar\">");
// iterate view.Articles
;(function(){
  var $$obj = view.Articles;
  if ('number' == typeof $$obj.length) {

    for (var $index = 0, $$l = $$obj.length; $index < $$l; $index++) {
      var article = $$obj[$index];

buf.push("<li><a" + (jade.attr("href", '/help/' + article.Id, true, true)) + ">" + (jade.escape(null == (jade_interp = article.Title) ? "" : jade_interp)) + "</a></li>");
    }

  } else {
    var $$l = 0;
    for (var $index in $$obj) {
      $$l++;      var article = $$obj[$index];

buf.push("<li><a" + (jade.attr("href", '/help/' + article.Id, true, true)) + ">" + (jade.escape(null == (jade_interp = article.Title) ? "" : jade_interp)) + "</a></li>");
    }

  }
}).call(this);

buf.push("</ul>");
    }

  } else {
    var $$l = 0;
    for (var $index in $$obj) {
      $$l++;      var view = $$obj[$index];

buf.push("<h4>" + (jade.escape(null == (jade_interp = view.Title) ? "" : jade_interp)) + "</h4><ul class=\"sidebar\">");
// iterate view.Articles
;(function(){
  var $$obj = view.Articles;
  if ('number' == typeof $$obj.length) {

    for (var $index = 0, $$l = $$obj.length; $index < $$l; $index++) {
      var article = $$obj[$index];

buf.push("<li><a" + (jade.attr("href", '/help/' + article.Id, true, true)) + ">" + (jade.escape(null == (jade_interp = article.Title) ? "" : jade_interp)) + "</a></li>");
    }

  } else {
    var $$l = 0;
    for (var $index in $$obj) {
      $$l++;      var article = $$obj[$index];

buf.push("<li><a" + (jade.attr("href", '/help/' + article.Id, true, true)) + ">" + (jade.escape(null == (jade_interp = article.Title) ? "" : jade_interp)) + "</a></li>");
    }

  }
}).call(this);

buf.push("</ul>");
    }

  }
}).call(this);

}
buf.push("</div></div></div><div id=\"help-docs\" class=\"column-6\"><div class=\"lge-container\">");
if ( title)
{
buf.push("<h2>" + (jade.escape(null == (jade_interp = title) ? "" : jade_interp)) + "</h2>");
}
buf.push((null == (jade_interp = content) ? "" : jade_interp) + "</div></div></div></div></body></html>");
}}.call(this,"loggedIn" in locals_for_with?locals_for_with.loggedIn:typeof loggedIn!=="undefined"?loggedIn:undefined,"library" in locals_for_with?locals_for_with.library:typeof library!=="undefined"?library:undefined,"title" in locals_for_with?locals_for_with.title:typeof title!=="undefined"?title:undefined,"content" in locals_for_with?locals_for_with.content:typeof content!=="undefined"?content:undefined));;return buf.join("");
}