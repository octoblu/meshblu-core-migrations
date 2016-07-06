_               = require 'lodash'
async           = require 'async'
mongojs         = require 'mongojs'
Datastore       = require 'meshblu-core-datastore'
TokensMigration = require '../../src/migrations/tokens-migration'
devices         = require './tokens-migrations-devices'
tokens          = require './tokens-migrations-tokens'

describe 'TokensMigration', ->
  beforeEach ->
    @database = mongojs 'meshblu-core-tokens-migration-spec', ['devices', 'tokens']
    @datastores = {}
    @datastores.devices = new Datastore { @database, collection: 'devices' }
    @datastores.tokens = new Datastore { @database, collection: 'tokens' }
    @sut = new TokensMigration { @datastores }

  beforeEach (done) ->
    @database.devices.remove done

  beforeEach (done) ->
    @database.tokens.remove done

  describe '->up', ->
    beforeEach (done) ->
      @datastores.devices.insert devices, done

    beforeEach (done) ->
      @sut.up done

    it 'should convert to the tokens', (done) ->
      @datastores.tokens.find {uuid: {$exists: true}}, (error, records) =>
        return done error if error?
        expect(_.sortBy(records, 'hashedToken')).to.deep.equal _.sortBy(tokens, 'hashedToken')
        done()

    it 'should not exist in devices', (done) ->
      @datastores.devices.find {uuid: {$exists: true}}, (error, records) =>
        return done error if error?
        _.each records, (record) =>
          expect(record.meshblu.tokens).to.not.exist
        done()

  xdescribe '->down', ->
    beforeEach (done) ->
      @datastores.tokens.insert tokens, done

    beforeEach (done) ->
      @sut.down done

    it 'should convert back to the devices', (done) ->
      @datastores.devices.find {uuid: {$exists: true}}, (error, records) =>
        return done error if error?
        expect(records).to.deep.equal devices
