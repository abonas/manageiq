topologyApp = angular.module('topologyApp', ['kubernetesUI']);
topologyApp.config(['$httpProvider', function($httpProvider) {
    $httpProvider.defaults.headers.common['X-CSRF-Token'] = jQuery('meta[name=csrf-token]').attr('content');
}]);

topologyApp.controller('containerTopologyController', ['$scope', '$http', '$interval', "$location",  function($scope, $http, $interval, $location) {
    $scope.refresh = function() {
        var id;
        if ($location.absUrl().match("show/$") || $location.absUrl().match("show$")) {
           id = '';
        }
        else {
            id = '/'+ (/container_topology\/show\/(\d+)/.exec($location.absUrl())[1]);
        }

        var url = '/container_topology/data'+id;
        $http.get(url).success(function(data) {
            $scope.items = data.data.items;
            $scope.relations = data.data.relations;
            $scope.kinds = data.data.kinds;
        });

    };

    $scope.refresh();
    $interval( $scope.refresh, 1000*60);
}]);
