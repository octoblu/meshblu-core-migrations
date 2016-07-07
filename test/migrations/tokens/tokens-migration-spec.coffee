_               = require 'lodash'
async           = require 'async'
mongojs         = require 'mongojs'
Datastore       = require 'meshblu-core-datastore'
TokensMigration = require '../../../src/migrations/tokens-migration'
devices         = require './assets/tokens-migration-devices.cson'
tokens          = require './assets/tokens-migration-tokens.cson'

describe 'TokensMigration', ->
  beforeEach ->
    database = mongojs 'meshblu-core-tokens-migration-spec'
    @devicesCollection = database.collection 'devices'
    @tokensCollection = database.collection 'tokens'
    @sut = new TokensMigration { database }

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

    describe 'when the devices collection is validated', ->
      beforeEach (done) ->
        @devicesCollection.find {uuid: {$exists: true}}, {_id: false}, (error, @records) =>
          done error

      it 'should have the root token', ->
        _.each @records, (record) =>
          expect(record.token).to.exist

      it 'should not have the session tokens', ->
        _.each @records, (record) =>
          expect(record.tokens).to.not.exist

  describe '->down', ->
    beforeEach (done) ->
      @tokensCollection.insert _.cloneDeep(tokens), done

    beforeEach (done) ->
      @devicesCollection.insert _.cloneDeep(devices), done

    beforeEach (done) ->
      @sut.down done

    it 'should convert back to the devices', (done) ->
      @devicesCollection.find {}, {_id: false}, (error, records) =>
        return done error if error?
        expect(records).to.deep.equal devices
        done()
