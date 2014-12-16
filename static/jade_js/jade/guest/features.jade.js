var jade = require('jade/lib/runtime.js'); 
module.exports = function template(locals) {
var buf = [];
var jade_mixins = {};
var jade_interp;

jade_mixins["footer-div"] = function(){
var block = (this && this.block), attributes = (this && this.attributes) || {};
buf.push("<div id=\"footer\"><div class=\"row\"><div class=\"column-offset-2 column-8\"><img src=\"/static/assets/logos/si-logo.png\"/><a href=\"terms-and-conditions.html\">Terms & Conditions</a></div></div></div>");
};
jade_mixins["call-to-action-div"] = function(){
var block = (this && this.block), attributes = (this && this.attributes) || {};
buf.push("<div id=\"call-to-action\"><div class=\"row\"><div class=\"column-offset-2 column-8\"><h1>Security Risk. Understood.</h1><br/><br/><a href=\"getting-started.html\"><button type=\"button\">See for yourself</button></a></div></div></div>");
};
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
buf.push("</ul></div></div></div><div id=\"features\"><h2>TEAM Mentor provides intelligence to fix vulnerabilities and comply</h2><br><div class=\"row\"><div class=\"column-offset-3 column-1\"><img src=\"/deploy/assets/icons/compliance.png\" alt=\"Delivers compliance-specific secure coding guidance\"></div><div class=\"column-5\"><h4>Delivers compliance-specific secure coding guidance for PCI-DSS, OWASP Top 10, CWE and other popular frameworks.</h4></div></div><br><div class=\"row\"><div class=\"column-offset-3 column-1\"><img src=\"/deploy/assets/icons/integrate.png\" alt=\"Integrates with multiple static analysis tools and developer environments\"></div><div class=\"column-5\"><h4>Integrates with multiple static analysis tools and developer environments (IDE’s) to map prescriptive coding guidance to scan results to fix vulnerabilities.</h4></div></div><br><div class=\"row\"><div class=\"column-offset-3 column-1\"><img src=\"/deploy/assets/icons/crossreferences.png\" alt=\"Stores and cross-references your security policies\"></div><div class=\"column-5\"><h4>Stores and cross-references your security policies with out-of-the-box secure coding checklists and examples.</h4></div></div><br><div class=\"row\"><div class=\"column-offset-3 column-1\"><img src=\"/deploy/assets/icons/reduces.png\" alt=\"Provides guidance to assist developers\"></div><div class=\"column-5\"><h4>Provides guidance to assist developers in reducing security vulnerabilities in software applications.</h4></div></div></div>");
jade_mixins["call-to-action-div"]();
jade_mixins["footer-div"]();
buf.push("</body></html>");;return buf.join("");
}