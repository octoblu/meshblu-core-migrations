_          = require 'lodash'
async      = require 'async'
mongojs    = require 'mongojs'
Datastore  = require 'meshblu-core-datastore'
migrations = require '../../../src/migrations'
devices    = require './assets/devices.cson'
newDevices = require './assets/new-devices.cson'
tokens     = require './assets/tokens.cson'

describe 'RemoveDeviceTokensMigration', ->
  beforeEach ->
    database = mongojs 'meshblu-core-tokens-migration-spec'
    @devicesCollection = database.collection 'devices'
    @tokensCollection = database.collection 'tokens'
    RemoveDeviceTokensMigration = migrations['remove-device-tokens']
    @sut = new RemoveDeviceTokensMigration { database }

  beforeEach (done) ->
    @devicesCollection.remove done

  beforeEach (done) ->
    @tokensCollection.remove done

  describe '->up', ->
    beforeEach (done) ->
      @devicesCollection.insert _.cloneDeep(devices), (error) =>
        done error

    beforeEach (done) ->
      @sut.up done

    describe 'when the devices collection is validated', ->
      beforeEach (done) ->
        @devicesCollection.find {uuid: {$exists: true}}, {_id: false}, (error, @records) =>
          done error

      it 'should have the root token', ->
        _.each @records, (record) =>
          expect(record.token).to.exist

      it 'should not have the session tokens', ->
        _.each @records, (record) =>
          expect(record.meshblu.tokens).to.not.exist

  describe '->down', ->
    beforeEach (done) ->
      @tokensCollection.insert _.cloneDeep(tokens), done

    beforeEach (done) ->
      @devicesCollection.insert _.cloneDeep(newDevices), done

    beforeEach (done) ->
      @sut.down done

    it 'should convert back to the devices', (done) ->
      @devicesCollection.find {}, {_id: false}, (error, records) =>
        return done error if error?
        expect(_.sortBy(records, 'uuid')).to.deep.equal _.sortBy(devices, 'uuid')
        done()
