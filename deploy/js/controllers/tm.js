//defining module
var app = angular.module('tm', ['ngSanitize']);

//defining TMService factory
app.factory("TMService", function ($http, $q){
   return {
			  ProcessHttpRequest : function () {
				  return $q.all([$http.get("/rest/library/eb39d862-f752-4d1c-ab6e-14ed697397c0",{cache:true}),
								 $http.post("/Aspx_Pages/TM_WebServices.asmx/GetGUIObjects", {headers:{'Content-Type':'application/json'}})
								]);
	  },
	   fetchArticleContent : function(id){
		 var url ="/Aspx_Pages/TM_WebServices.asmx/GetGuidanceItemHtml";
	     return $q.all($http({
				url: url,
				method: "POST",
				data :{ guidanceItemId : id},
				headers:{'Content-Type':'application/json'}}));
	   }
	}
});

app.controller("libraryController",function ($scope,$http,$sce,TMService){
$scope.fetched = true;
$scope.isCollapsed= true;
	TMService.ProcessHttpRequest().then(function (serviceResponse){
			var  libraryResponse = serviceResponse[0].data;
			var  guiObjects = serviceResponse[1].data;
			var  articleMetadata = getArticlesMetadata (guiObjects);
			$scope.tmLibrary=  getLibrary(libraryResponse, articleMetadata);
		    $scope.rendered = true;			
});

//Fetch article content	
$scope.getContentAsync = function (articleId,title)
{
	 var h1Title = "<h1> " + title + " </h1>";
	 TMService.fetchArticleContent(articleId).then(function(response){
		 	$scope.payload =h1Title.concat(response.data.d.toString());
		  	$scope.body = $sce.trustAsHtml( $scope.payload);
	  });
};

});

getArticlesMetadata = function(guiObjects)
  {
        var articlesMetadata = {};
        var mappings      = guiObjects.d.GuidanceItemsMappings;
        var uniqueStrings = guiObjects.d.UniqueStrings;
        articlesMetadata._numberOfArticles = 0;
    
        angular.forEach(mappings,(function(mapping)
            {
                var keys = mapping.split(',');                
                var metadata = {    Id         : uniqueStrings[keys[0]],
                                    Title      : uniqueStrings[keys[2]],
                                    Technology : uniqueStrings[keys[3]],
                                    Phase      : uniqueStrings[keys[4]],
                                    Type       : uniqueStrings[keys[5]],
                                    Category   : uniqueStrings[keys[6]]};
                
                articlesMetadata[metadata.Id]= metadata;  
                articlesMetadata._numberOfArticles++;
            }));        
        return articlesMetadata;
    };

//Function returns library
getLibrary = function(libraryInfo, metadata){
var library = {                                       
                    Title   : libraryInfo.name,
                    Folders : [],
                    Views   : [],
                    Articles: {}
   				};
var tmViews = libraryInfo.views;
			
angular.forEach(tmViews, function (tmview){
	var view = {Title: tmview.caption, Articles: []}
	angular.forEach(tmview.guidanceItems,function (guidanceItem){
		
	 		var articlemetadata = metadata[guidanceItem];
		    view.Articles.push(articlemetadata);
			library.Articles[articlemetadata.Id] =articlemetadata;
	});
	library.Views.push(view);
}); 
			
  return library;
};                


