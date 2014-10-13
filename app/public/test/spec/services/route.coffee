'use strict'

describe 'Service: route', ->

  # load the service's module
  beforeEach module 'uiApp'

  # instantiate service
  route = {}
  beforeEach inject (_route_) ->
    route = _route_

  it 'should do something', ->
    expect(!!route).toBe true
