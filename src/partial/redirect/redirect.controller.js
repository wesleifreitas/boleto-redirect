(function() {
    'use strict';

    angular.module('myApp').controller('RedirectCtrl', RedirectCtrl);

    RedirectCtrl.$inject = ['config', 'exampleService', '$rootScope', '$scope', '$state', '$mdDialog'];

    function RedirectCtrl(config, exampleService, $rootScope, $scope, $state, $mdDialog) {

        var vm = this;

        vm.numeral = numeral;
        vm.initFlow = initFlow;
        vm.setFlowOptions = setFlowOptions;
        vm.getProgress = getProgress;
        vm.fileAdded = fileAdded;
        vm.fileSuccess = fileSuccess;

        // Inicializar ng-flow : https://github.com/flowjs/ng-flow
        function initFlow() {
            return {
                chunkSize: 104857600, // 100mb
                target: config.REST_URL + '/redirect/upload',
                query: {
                    type: 'redirect'
                }
            };
        }

        //console.log(config);

        function setFlowOptions($flow) {
            //console.info('setFlowOptions', $flow);
            $scope.operacao = moment().format('YYYYMMDDHHmmss');
            $flow.opts.query.grupo = 1;
            $flow.opts.query.cedente = 1;
            $flow.opts.query.operacao = $scope.operacao;
            $flow.resume();
        }

        // Armazenar tranferências finalizadas independente 
        // se foram com sucesso ou não
        vm.transfersFinished = [];
        vm.removeSuccessLine = removeSuccessLine;

        function removeSuccessLine(event, index, file, transfers) {
            console.log(removeSuccessLine);
            // Armazenar index da transferência
            vm.transfersFinished.push(index);
            // Verificar se todas as tranferências foram finalizadas
            // independente se houve falhas
            if (vm.transfersFinished.length === transfers.length) {
                // Ordenar índicies das tranferências finalizadas
                vm.transfersFinished.sort(function(a, b) {
                    return b - a;
                });
                //console.info('sort', vm.transfersFinished);
                // Loop nas tranferências finalizadas
                for (var i = vm.transfersFinished.length - 1; i >= 0; i--) {
                    //console.info(transfers[i]);
                    // Verificar se a transferência do loop foi finalizad com sucesso
                    if (transfers[i]._prevProgress === 1) {
                        // Remover item com sucesso da listagem (área de transferência)
                        transfers.splice(i, 1);
                    }
                }
                // Resetar transfersFinished
                vm.transfersFinished = [];

                redirectLog();

                /*$mdDialog.show({
                    scope: $scope,
                    preserveScope: true,
                    templateUrl: 'contabil/partial/upload/upload-dialog.html',
                    parent: angular.element(document.body),
                    //targetEvent: event,
                    clickOutsideToClose: true
                });*/
            }
            /*
            console.group('removeSuccessLine');
            console.info('index', index);
            console.info('file', file);
            console.info('transfers', transfers);
            console.groupEnd();
            */
        }

        // Retornar % do progresso de upload
        function getProgress(value) {
            return parseInt(value * 100);
        }


        // Evento fileAdded
        function fileAdded($file, $event, $flow) {
            $file.finished = false;

            console.group('flow::fileAdded');
            console.info('$flow', $flow);
            console.info('$file', $file);
            console.groupEnd();


            // Verificar arquivos que serão ignorados:
            // > 100mb
            if ($file.size > 104857600) {
                event.preventDefault(); //prevent file from uploading
            }
        }

        // Evento fileSuccess 
        function fileSuccess($file, $message, $flow) {
            $file.finished = true;

            console.group('flow::fileSuccess');
            console.info('$file', $file);
            console.info('$message', $message);
            console.info('$flow', $flow);
            console.info('$scope.transfers', $scope.transfers);
            console.groupEnd();

        }

        function redirectLog() {
            var locals = {};
            $mdDialog.show({
                locals: locals,
                preserveScope: true,
                controller: 'RedirectDialogCtrl',
                controllerAs: 'vm',
                templateUrl: 'partial/redirect/redirect-dialog.html',
                parent: angular.element(document.body),
                //targetEvent: event,
                clickOutsideToClose: false
            }).then(function(data) {
                //console.info(data);
            });
        }
    }
})();