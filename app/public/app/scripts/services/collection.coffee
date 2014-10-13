'use strict'

###*
 # @ngdoc service
 # @name uiApp.collection
 # @description
 # # collection
 # Service in the uiApp.
###
angular.module('uiApp')
  .service 'Collection', ($resource) ->
    x2js = new X2JS
    return $resource('/query/:query', {}, {
        query: 
          method: 'GET',
          transformResponse: (response) ->
            obj = x2js.xml_str2json(response)
            return obj
      })
