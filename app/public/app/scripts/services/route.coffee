'use strict'

###*
 # @ngdoc service
 # @name uiApp.route
 # @description
 # # route
 # Service in the uiApp.
###
angular.module('uiApp')
  .service 'Route', ->

    route =
      current: 'list'
      article: {}
      viewArticle: (article) ->
        route.article = article
        route.current = 'single'
      list: ->
        route.current = 'list'

    return route