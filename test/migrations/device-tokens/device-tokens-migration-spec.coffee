_          = require 'lodash'
async      = require 'async'
mongojs    = require 'mongojs'
Datastore  = require 'meshblu-core-datastore'
migrations = require '../../../src/migrations'
devices    = require './assets/devices.cson'
tokens     = require './assets/tokens.cson'

describe 'DeviceTokensMigration', ->
  beforeEach ->
    database = mongojs 'meshblu-core-tokens-migration-spec'
    @devicesCollection = database.collection 'devices'
    @tokensCollection = database.collection 'tokens'
    DeviceTokensMigration = migrations['device-tokens']
    @sut = new DeviceTokensMigration { database }

  beforeEach (done) ->
    @devicesCollection.remove done

  beforeEach (done) ->
    @tokensCollection.remove done

  describe '->up', ->
    beforeEach (done) ->
      @devicesCollection.insert _.cloneDeep(devices), (error) =>
        done error

    describe 'when called and no tokens exist', ->
      beforeEach (done) ->
        @sut.up done

      it 'should have the correct indexes', (done) ->
        @tokensCollection.getIndexes (error, indexes) =>
          return done error if error?
          expect(_.map(indexes, 'key')).to.deep.equal [
            {
              _id: 1
            },
            {
              uuid: -1
              hashedToken: -1
            }
          ]
          done()

      it 'should convert to the tokens', (done) ->
        @tokensCollection.find {}, {_id: false}, (error, records) =>
          return done error if error?
          sortedTokens = _.sortBy(tokens, 'hashedToken')
          sortedRecords = _.sortBy(records, 'hashedToken')
          expect(sortedRecords).to.deep.equal sortedTokens
          done()

      it 'should have the same devices', (done) ->
        @devicesCollection.find {}, {_id: false}, (error, records) =>
          return done error if error?
          expect(_.sortBy(records, 'uuid')).to.deep.equal _.sortBy(devices, 'uuid')
          done()

    describe 'when called and tokens exist', ->
      beforeEach (done) ->
        @tokensCollection.insert _.cloneDeep(tokens), (error) =>
          done error

      beforeEach (done) ->
        @sut.up done

      it 'should have the correct indexes', (done) ->
        @tokensCollection.getIndexes (error, indexes) =>
          return done error if error?
          expect(_.map(indexes, 'key')).to.deep.equal [
            {
              _id: 1
            },
            {
              uuid: -1
              hashedToken: -1
            }
          ]
          done()

      it 'should convert to the tokens', (done) ->
        @tokensCollection.find {}, {_id: false}, (error, records) =>
          return done error if error?
          sortedTokens = _.sortBy(tokens, 'hashedToken')
          sortedRecords = _.sortBy(records, 'hashedToken')
          expect(sortedRecords).to.deep.equal sortedTokens
          done()

      it 'should have the same devices', (done) ->
        @devicesCollection.find {}, {_id: false}, (error, records) =>
          return done error if error?
          expect(_.sortBy(records, 'uuid')).to.deep.equal _.sortBy(devices, 'uuid')
          done()

  describe '->down', ->
    beforeEach (done) ->
      @sut.down (@error) =>
        done()

    it 'should throw an error', ->
      expect(@error).to.exist
