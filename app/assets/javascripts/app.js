'use strict';

var dataset = document.getElementById('asset-helpers').dataset

angular.module('MAGI',['btford.dragon-drop','ui.mask','MAGI.filters','MAGI.services',
             'MAGI.directives','MAGI.controllers']).
  config(['$routeProvider', function($routeProvider) {
    $routeProvider.when('/application', {templateUrl: dataset.formUrl, controller: 'FormController'});
    $routeProvider.when('/results', {templateUrl: dataset.resultsUrl, controller:  'ResultsController'});
    $routeProvider.when('/exportimport', {templateUrl: dataset.exportimportUrl, controller: 'ExportImportController'});
    $routeProvider.when('/exportraw', {templateUrl: dataset.exportrawUrl, controller: 'ExportRawController'});
    $routeProvider.otherwise({redirectTo: '/application'});
  }]);
