(function() {
    'use strict';

    angular
        .module('myApp')
        .config(configure);

    configure.$inject = ['$stateProvider'];

    function configure($stateProvider) {
        $stateProvider.state('redirect', getState());
    }

    function getState() {
        return {
            url: '/redirect',
            templateUrl: 'partial/redirect/redirect.html',
            controller: 'RedirectCtrl',
            controllerAs: 'vm',
            parent: 'home',
            params: {
                'id': null
            },
        };
    }
})();