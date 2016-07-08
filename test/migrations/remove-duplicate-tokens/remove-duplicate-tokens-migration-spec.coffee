_          = require 'lodash'
async      = require 'async'
mongojs    = require 'mongojs'
Datastore  = require 'meshblu-core-datastore'
migrations = require '../../../src/migrations'
tokens     = require './assets/tokens.cson'
dupTokens     = require './assets/dup-tokens.cson'

describe 'RemoveDuplicateTokens', ->
  beforeEach ->
    database = mongojs 'meshblu-core-tokens-migration-spec'
    @tokensCollection = database.collection 'tokens'
    RemoveDuplicateTokens = migrations['remove-duplicate-tokens']
    @sut = new RemoveDuplicateTokens { database }

  beforeEach (done) ->
    @tokensCollection.remove done

  describe '->up', ->
    beforeEach (done) ->
      @tokensCollection.insert _.cloneDeep(dupTokens), (error) =>
        done error

    beforeEach (done) ->
      @sut.up done

    it 'should have no dups', (done) ->
      @tokensCollection.find {}, {_id: false}, (error, records) =>
        return done error if error?
        sortedTokens = _.sortBy(tokens, 'hashedToken')
        sortedRecords = _.sortBy(records, 'hashedToken')
        expect(sortedRecords).to.deep.equal sortedTokens
        done()
