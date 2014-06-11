chai = require 'chai'
sinon = require 'sinon'
chai.use require 'sinon-chai'

expect = chai.expect

describe 'stashboard', ->
  beforeEach ->
    @robot =
      respond: sinon.spy()
      hear: sinon.spy()

    require('../src/stashboard')(@robot)

  it 'registers a stashboard status listener', ->
    expect(@robot.respond).to.have.been.calledWith(/stashboard (status|sup|\?)/i)

  it 'registers a stashboard set listener', ->
    expect(@robot.respond).to.have.been.calledWith(/stashboard set (.*?) (.*?) (.*)/i)
