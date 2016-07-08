_          = require 'lodash'
async      = require 'async'
mongojs    = require 'mongojs'
Datastore  = require 'meshblu-core-datastore'
migrations = require '../../../src/migrations'
tokens     = require './assets/tokens.cson'
expiredTokens = require './assets/expired-tokens.cson'

describe 'RemoveExpiredTokens', ->
  beforeEach ->
    database = mongojs 'meshblu-core-tokens-migration-spec'
    @tokensCollection = database.collection 'tokens'
    RemoveExpiredTokens = migrations['remove-expired-tokens']
    @sut = new RemoveExpiredTokens { database }

  beforeEach (done) ->
    @tokensCollection.remove done

  describe '->up', ->
    beforeEach (done) ->
      _tokens = _.map _.cloneDeep(expiredTokens), (token) =>
        token.expiresOn = new Date(token.expiresOn) if token.expiresOn?
        return token

      @tokensCollection.insert _tokens, (error) =>
        done error

    beforeEach (done) ->
      @sut.up done

    it 'should have no expired tokens', (done) ->
      @tokensCollection.find {}, {_id: false}, (error, records) =>
        return done error if error?
        _tokens = _.map _.cloneDeep(tokens), (token) =>
          token.expiresOn = new Date(token.expiresOn) if token.expiresOn?
          return token
        sortedTokens = _.sortBy(_tokens, 'hashedToken')
        sortedRecords = _.sortBy(records, 'hashedToken')
        expect(sortedRecords).to.deep.equal sortedTokens
        done()
