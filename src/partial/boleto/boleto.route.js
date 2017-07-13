(function() {
    'use strict';

    angular
        .module('myApp')
        .config(configure);

    configure.$inject = ['$stateProvider'];

    function configure($stateProvider) {
        $stateProvider.state('boleto', getState());
    }

    function getState() {
        return {
            url: '/boleto',
            templateUrl: 'partial/boleto/boleto.html',
            controller: 'BoletoCtrl',
            controllerAs: 'vm',
            parent: 'home',
            params: {
                'id': null
            },
        };
    }
})();