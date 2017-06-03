(function() {
    'use strict';

    angular.module('myApp').controller('RedirectDialogCtrl', RedirectDialogCtrl);

    RedirectDialogCtrl.$inject = ['config', 'redirectService', '$rootScope', '$scope', '$state', '$mdDialog'];

    function RedirectDialogCtrl(config, redirectService, $rootScope, $scope, $state, $mdDialog) {

        var vm = this;
        vm.init = init;
        vm.example = {
            limit: 10,
            page: 1,
            selected: [],
            order: '',
            data: [],
            //pagination: pagination,
            total: 0
        };
        vm.close = close;

        function init() {

            getData();
        }

        /*function pagination(page, limit) {
            vm.example.data = [];
            getData();
        }*/

        function getData() {
            vm.example.promise = redirectService.get()
                .then(function success(response) {
                    //console.info('success', response);
                    vm.example.total = response.query.length;
                    vm.example.data = vm.example.data.concat(response.query);
                }, function error(response) {
                    console.error('error', response);
                });
        }

        function close() {
            $mdDialog.cancel();
        }
    }
})();