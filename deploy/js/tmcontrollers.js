var app = angular.module('tm', ['ngSanitize']);

app.controller("NavigationController", ['$scope', '$sce','$http','$q', function($scope, $sce,$http,$q) {
	
$scope.init = function () {
		$scope.rendered = false;
       $scope.GetViews();  
}
//Promises
$scope.GetViews = function() {
var first  = $http.get("/rest/library/eb39d862-f752-4d1c-ab6e-14ed697397c0"),
    second = $http.post("/Aspx_Pages/TM_WebServices.asmx/GetGUIObjects",{headers:{'Content-Type':'application/json'}});

$q.all([first, second]).then(function(result) {
var tmp = [];
angular.forEach(result, function(response) {
   tmp.push(response.data);
});
      return tmp;
}).then(function(result) 
{
   $scope.buildUI(result);
	//Pulling views
   $scope.views = result[0].views;
   $scope.rendered = true;
});
};

$scope.buildUI = function(data) {
	var guidanceItems = data[1].d.GuidanceItemsMappings;
	var uniqueStrings = data[1].d.UniqueStrings; 
	var views         = data[0].views;
	$scope.results=[];
	angular.forEach(guidanceItems, function(key,value){
		//Parsing results
		var indexes = key.split(',');
		mapping ={
					guidanceItemId: uniqueStrings[indexes[0]],
					libraryId: uniqueStrings[indexes[1]],
					title: uniqueStrings[indexes[2]], 
					technology: uniqueStrings[indexes[3]], 
					phase: uniqueStrings[indexes[4]],
					type: uniqueStrings[indexes[5]],
					category: uniqueStrings[indexes[6]]
				}; 
			$scope.results[mapping.guidanceItemId] = mapping;
	});
};
$scope.init();

$scope.ShowContent = function (articleId,title)
{
	  //Fetching article content
	  var url ="/Aspx_Pages/TM_WebServices.asmx/GetGuidanceItemHtml";
	  $http({
				url: url,
				method: "POST",
				data :{ guidanceItemId : articleId},
				headers:{'Content-Type':'application/json'}
	  }).then (function (response)
	  {
		  var titleA = "<h1>" + title + "</h1></br>";
		  $scope.payload =titleA.concat(response.data.d.toString());
		  $scope.body = $sce.trustAsHtml( $scope.payload);
	  });
};
}]);
