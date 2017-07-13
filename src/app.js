(function() {
    'use strict';

    const PROJECT_NAME = 'myApp';
    const DEMO = false;

    angular
        .module(PROJECT_NAME, [
            'ui.router',
            'ngCookies',
            'ngMaterial',
            'ngMessages',
            'ui.utils.masks',
            'ui.mask',
            'idf.br-filters',
            'ng-currency',
            'md.data.table',
            'fixed.table.header',
            'angular-loading-bar',
            'flow'
        ])
        .config(config)
        .run(run);

    angular
        .module(PROJECT_NAME)
        .factory('httpRequestInterceptor', function() {
            return {
                request: function(config) {
                    return config;
                }
            };
        });

    angular.module(PROJECT_NAME).constant('config', {
        'DEMO': DEMO,
        // RESTful - ColdFusion
        // Registrar REST: http://localhost:8500/px-boleto-redirect/backend/cf/restInit.cfm
        'REST_URL': window.location.origin + '/rest/px-boleto-redirect',
    });

    config.$inject = ['$stateProvider', '$urlRouterProvider', '$mdThemingProvider', '$mdDateLocaleProvider',
        'cfpLoadingBarProvider', '$httpProvider', 'flowFactoryProvider'
    ];

    function config($stateProvider, $urlRouterProvider, $mdThemingProvider, $mdDateLocaleProvider,
        cfpLoadingBarProvider, $httpProvider, flowFactoryProvider) {

        $httpProvider.interceptors.push('httpRequestInterceptor');

        cfpLoadingBarProvider.includeSpinner = false;

        $urlRouterProvider.otherwise(function($injector) {
            var $state = $injector.get('$state');
            if (DEMO) {
                $state.go('redirect');
            } else {
                $state.go('login');
            }
        });

        moment.locale('pt-BR');

        // https://material.angularjs.org/latest/api/service/$mdDateLocaleProvider
        $mdDateLocaleProvider.months = ['janeiro',
            'fevereiro',
            'março',
            'abril',
            'maio',
            'junho',
            'julho',
            'agosto',
            'setembro',
            'outubro',
            'novembro',
            'dezembro'
        ];
        $mdDateLocaleProvider.shortMonths = ['jan.',
            'fev',
            'mar',
            'abr',
            'maio',
            'jun',
            'jul',
            'ago',
            'set',
            'out',
            'nov',
            'dez'
        ];
        $mdDateLocaleProvider.parseDate = function(dateString) {
            var m = moment(dateString, 'L', true);
            return m.isValid() ? m.toDate() : new Date(NaN);
        };
        $mdDateLocaleProvider.formatDate = function(date) {
            if (moment(date).format('L') === 'Invalid date') {
                return '';
            } else {
                return moment(date).format('L');
            }
        };

        flowFactoryProvider.defaults = {
            testChunks: false,
            permanentErrors: [404, 500, 501],
            maxChunkRetries: 1,
            chunkRetryInterval: 5000,
            simultaneousUploads: 4,
        };
    }

    run.$inject = ['$rootScope', '$state', '$cookies', '$http'];

    function run($rootScope, $state, $cookies, $http) {

        if (DEMO) {
            // fake
            $rootScope.globals = {
                currentUser: {
                    username: 'admin',
                    userid: 0
                }
            };
            return;
        }

        // keep user logged in after page refresh
        $rootScope.globals = $cookies.getObject('globals') || {};
        if ($rootScope.globals.currentUser) {
            $http.defaults.headers.common['Authorization'] = 'Basic ' + $rootScope.globals.currentUser.authdata; // jshint ignore:line
        }

        $rootScope.$on('$stateChangeStart', function(event, toState, toParams) {

            var filterLast = JSON.parse(localStorage.getItem('filter')) || {};

            if (!filterLast[toState.url.split('/')[1]]) {
                localStorage.removeItem('filter');
            }

            if (toState.name === 'login' || toState.name === 'register') {
                return;
            } else {
                var loggedIn = $rootScope.globals.currentUser;
                if (!loggedIn) {
                    $state.go('login');
                    localStorage.removeItem('filter');
                    event.preventDefault();
                } else if (toState.name === 'home') {
                    // redirecionar o primeiro state
                    $state.go('boleto');
                    event.preventDefault();
                }
            }
        });
    }
})();