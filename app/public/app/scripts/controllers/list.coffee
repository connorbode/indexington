'use strict'

###*
 # @ngdoc function
 # @name uiApp.controller:MainCtrl
 # @description
 # # MainCtrl
 # Controller of the uiApp
###
angular.module('uiApp')
  .controller 'ListCtrl', ($scope, $timeout, Collection, Route) ->

    # timeout for query
    queryPromise = null

    # watch for query changes
    $scope.queryChanged = (query) ->
      $scope.results = []
      runQ = -> $scope.runQuery(query)
      $timeout.cancel(queryPromise) if queryPromise
      queryPromise = $timeout(runQ, 300)

    $scope.runQuery = (query) ->
      $scope.results = Collection.query({query: query}) if query != ""

    $scope.viewArticle = (article) ->
      Route.viewArticle(article)

    $scope.route = Route