(function() {
    'use strict';

    angular.module('myApp').controller('BoletoPDfDialogCtrl', BoletoPDfDialogCtrl);

    BoletoPDfDialogCtrl.$inject = ['$mdDialog', 'locals', '$mdToast', 'boletoService', 'stringUtil'];

    function BoletoPDfDialogCtrl($mdDialog, locals, $mdToast, boletoService, stringUtil) {

        var vm = this;
        vm.init = init;
        vm.pdfViewer = '';
        vm.save = save;
        vm.cancel = cancel;

        function init(event) {
            //console.info('locals', locals);

            boletoService.pdf(locals.item)
                .then(function success(response) {
                    console.info('boletoService.pdf', response);
                    var blob = stringUtil.toBinary(response.pdf, 'application/pdf;base64');
                    var blobUrl = URL.createObjectURL(blob);

                    vm.pdfViewer = 'pdf-viewer/web/viewer.html?file=' + blobUrl;

                }, function error(response) {
                    $mdDialog.cancel();
                    console.error(response);
                });
        }

        function save() {

        }

        function cancel() {
            $mdDialog.cancel();
        }
    }
})();