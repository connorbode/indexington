'use strict'

###*
 # @ngdoc function
 # @name uiApp.controller:SinglectrlCtrl
 # @description
 # # SinglectrlCtrl
 # Controller of the uiApp
###
angular.module('uiApp')
  .controller 'SingleCtrl', ($scope, Route) ->
    
    $scope.route = Route

    $scope.back = ->
      Route.list()