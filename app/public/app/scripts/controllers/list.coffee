'use strict'

###*
 # @ngdoc function
 # @name uiApp.controller:MainCtrl
 # @description
 # # MainCtrl
 # Controller of the uiApp
###
angular.module('uiApp')
  .controller 'ListCtrl', ($scope, Collection, Route) ->

    # watch for query changes
    $scope.runQuery = (query) ->
      $scope.results = Collection.query({query: query}) if query != ""
      $scope.results = [] if query == ""

    $scope.viewArticle = (article) ->
      Route.viewArticle(article)

    $scope.route = Route