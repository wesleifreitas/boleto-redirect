(function() {
    'use strict';

    angular.module('myApp').controller('BoletoEmailDialogCtrl', BoletoEmailDialogCtrl);

    BoletoEmailDialogCtrl.$inject = ['$mdDialog', 'locals', '$mdToast', 'boletoService', 'stringUtil'];

    function BoletoEmailDialogCtrl($mdDialog, locals, $mdToast, boletoService, stringUtil) {

        var vm = this;
        vm.init = init;
        vm.pdfViewer = '';
        vm.save = save;
        vm.cancel = cancel;

        function init(event) {
            //console.info('locals', locals);
        }

        function save() {
            vm.loading = true;
            boletoService.setEmail({
                    boletoId: locals.item.BOL_ID,
                    userId: locals.item.USU_ID,
                    email: vm.email
                })
                .then(function success(response) {
                    console.info(response);
                    locals.item.USU_EMAIL = vm.email;
                    locals.item.BOL_EMAIL_ENVIADO = true;
                    $mdDialog.hide();
                }, function error(response) {
                    vm.loading = false;
                });
        }

        function cancel() {
            $mdDialog.cancel();
        }
    }
})();