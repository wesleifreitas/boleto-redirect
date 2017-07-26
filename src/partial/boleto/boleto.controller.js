(function() {
    'use strict';

    angular.module('myApp').controller('BoletoCtrl', BoletoCtrl);

    BoletoCtrl.$inject = ['config', 'boletoService', '$rootScope', '$scope', '$state', '$mdDialog'];

    function BoletoCtrl(config, boletoService, $rootScope, $scope, $state, $mdDialog) {

        var vm = this;
        vm.init = init;
        vm.getData = getData;
        vm.create = create;
        vm.update = update;
        vm.remove = remove;
        vm.boleto = {
            limit: 10,
            page: 1,
            selected: [],
            order: '',
            data: [],
            pagination: pagination,
            total: 0
        };
        vm.showPdf = showPdf;
        vm.setEmail = setEmail;

        // $on
        // https://docs.angularjs.org/api/ng/type/$rootScope.Scope
        $scope.$on('broadcastTest', function() {
            console.info('broadcastTest!');
            //getData();
        });

        function init() {

            var filterLast = JSON.parse(localStorage.getItem('filter')) || {};

            if (filterLast[$state.current.url.split('/')[1]]) {
                vm.filter = filterLast;
            } else {
                vm.filter = {};
                vm.filter[$state.current.url.split('/')[1]] = true;
                vm.filter.months = moment.months();
                vm.filter.ano = vm.filter.ano || moment().year();
                vm.filter.mes = vm.filter.mes || moment().month();
            }

            getData({ reset: true });
        }

        function pagination(page, limit) {
            vm.boleto.data = [];
            getData();
        }

        function getData(params) {

            params = params || {};

            vm.filter.page = vm.boleto.page;
            vm.filter.limit = vm.boleto.limit;

            if (params.reset) {
                vm.boleto.data = [];
            }

            localStorage.setItem('filter', JSON.stringify(vm.filter));
            vm.boleto.promise = boletoService.get(vm.filter)
                .then(function success(response) {
                    //console.info('success', response);
                    vm.boleto.total = response.recordCount;

                    for (var i = 0; i <= response.query.length - 1; i++) {
                        response.query[i].BOL_VENCIMENTO = new Date(response.query[i].BOL_VENCIMENTO);
                    }

                    vm.boleto.data = vm.boleto.data.concat(response.query);
                }, function error(response) {
                    console.error('error', response);
                });
        }

        function create() {
            //$state.go('boleto-form');
            var locals = {};

            $mdDialog.show({
                locals: locals,
                preserveScope: true,
                controller: 'BoletoDialogCtrl',
                controllerAs: 'vm',
                templateUrl: 'partial/boleto/boleto-dialog.html',
                parent: angular.element(document.body),
                //targetEvent: event,
                clickOutsideToClose: false
            }).then(function(data) {
                //console.info('create then', data);
                getData({ reset: true });
            });
        }

        function update(id) {
            $state.go('boleto-form', { id: id });
        }

        function remove() {

            var confirm = $mdDialog.confirm()
                .title('ATENÇÃO')
                .textContent('Deseja realmente remover o(s) item(ns) selecionado(s)?')
                .targetEvent(event)
                .ok('SIM')
                .cancel('NÃO');

            $mdDialog.show(confirm).then(function() {
                boletoService.remove(vm.boleto.selected)
                    .then(function success(response) {
                        if (response.success) {
                            $('.md-selected').remove();
                            vm.boleto.selected = [];
                        }
                    }, function error(response) {
                        console.error('error', response);
                    });
            }, function() {
                // cancel
            });
        }

        function showPdf(item) {
            var locals = {
                item: item
            };

            $mdDialog.show({
                locals: locals,
                preserveScope: true,
                controller: 'BoletoPDfDialogCtrl',
                controllerAs: 'vm',
                templateUrl: 'partial/boleto/boleto-pdf-dialog.html',
                parent: angular.element(document.body),
                //targetEvent: event,
                clickOutsideToClose: false
            }).then(function(data) {

            });
        }

        // salvar e enviar e-mail
        function setEmail(item) {
            var locals = {
                item: item
            };

            $mdDialog.show({
                locals: locals,
                preserveScope: true,
                controller: 'BoletoEmailDialogCtrl',
                controllerAs: 'vm',
                templateUrl: 'partial/boleto/boleto-email-dialog.html',
                parent: angular.element(document.body),
                //targetEvent: event,
                clickOutsideToClose: false
            }).then(function(data) {

            });
        }
    }
})();