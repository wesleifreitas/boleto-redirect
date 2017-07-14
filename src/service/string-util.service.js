(function() {
    'use strict';

    angular
        .module('myApp')
        .factory('stringUtil', stringUtil);

    stringUtil.$inject = [];

    function stringUtil() {
        var service = {};

        service.toBinary = toBinary;
        service.left = left;
        service.right = right;
        service.padLeft = padLeft;
        service.padRight = padRight;

        return service;

        /**
         * Calcular a representação binária dos dados codificados em Base64 ou de um documento PDF
         * @param  {String} data        dados codificado em Base64
         * @param  {String} contentType natureza do arquivo http://www.freeformatter.com/mime-types-list.html
         * @param  {Number} sliceSize   tamanho
         * @return {String}             representação binária dos dados
         */
        function toBinary(data, contentType, sliceSize) {
            contentType = contentType || '';
            sliceSize = sliceSize || 512;

            /* jshint ignore:start */
            var byteCharacters = atob(data);
            var byteArrays = [];

            for (var offset = 0; offset < byteCharacters.length; offset += sliceSize) {
                var slice = byteCharacters.slice(offset, offset + sliceSize);

                var byteNumbers = new Array(slice.length);
                for (var i = 0; i < slice.length; i++) {
                    byteNumbers[i] = slice.charCodeAt(i);
                }

                var byteArray = new Uint8Array(byteNumbers);

                byteArrays.push(byteArray);
            }

            var blob = new Blob(byteArrays, {
                type: contentType
            });
            return blob;
            /* jshint ignore:end */
        }

        function left(str, n) {
            if (n <= 0) {
                return '';
            } else if (n > String(str).length) {
                return str;
            } else {
                return String(str).substring(0, n);
            }
        }

        function right(str, n) {
            if (n <= 0) {
                return '';
            } else if (n > String(str).length) {
                return str;
            } else {
                var iLen = String(str).length;
                return String(str).substring(iLen, iLen - n);
            }
        }

        function padLeft(str, pad) {
            return (pad + str).slice(-pad.length);
        }

        function padRight(str, pad) {
            return (str + pad).substring(0, pad.length);
        }
    }

})();