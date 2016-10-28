_          = require 'lodash'
async      = require 'async'
mongojs    = require 'mongojs'
Datastore  = require 'meshblu-core-datastore'
migrations = require '../../../src/migrations'

describe 'AddIndexesMigration', ->
  beforeEach ->
    database = mongojs 'meshblu-core-add-indexes-migration-spec'
    AddIndexesMigration = migrations['add-indexes']
    @devicesCollection = database.collection 'devices'
    @sut = new AddIndexesMigration { database }

  beforeEach (done) ->
    @devicesCollection.remove done

  describe '->up', ->
    describe 'when called', ->
      beforeEach (done) ->
        @sut.up done

      it 'should have the correct indexes', (done) ->
        setTimeout =>
          @devicesCollection.getIndexes (error, indexes) =>
            return done error if error?
            expect(_.tail(_.map(indexes, 'key'))).to.deep.equal @sut.indexes.devices
            done()
        , 1000

  describe '->down', ->
    beforeEach (done) ->
      @sut.down (@error) =>
        done()

    it 'should throw an error', ->
      expect(@error).to.exist
