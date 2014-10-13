'use strict'

describe 'Controller: SinglectrlCtrl', ->

  # load the controller's module
  beforeEach module 'uiApp'

  SinglectrlCtrl = {}
  scope = {}

  # Initialize the controller and a mock scope
  beforeEach inject ($controller, $rootScope) ->
    scope = $rootScope.$new()
    SinglectrlCtrl = $controller 'SinglectrlCtrl', {
      $scope: scope
    }

  it 'should attach a list of awesomeThings to the scope', ->
    expect(scope.awesomeThings.length).toBe 3
