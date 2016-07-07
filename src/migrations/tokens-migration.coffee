_            = require 'lodash'
async        = require 'async'
MongoForEach = require '../helpers/mongo-for-each'

class TokensMigration
  constructor: ({ database }) ->
    @devices = database.collection 'devices'
    @tokens = database.collection 'tokens'

  up: (callback) =>
    @tokens.ensureIndex { uuid: -1, hashedToken: -1 }, (error) =>
      return callback error if error?
      query = { 'meshblu.tokens': $exists: true }
      projection = { uuid: true, 'meshblu': true, token: true }

      mongoForEach = new MongoForEach({ collection: @devices, taskFn: @_convertDevice })
      mongoForEach.do query, projection, callback

  down: (callback) =>
    query = { 'uuid': $exists: true }
    mongoForEach = new MongoForEach({ collection: @tokens, taskFn: @_convertToken })
    mongoForEach.do query, { _id: false }, callback

  _convertToken: ({ uuid, hashedToken, metadata }, callback) =>
    updateQuery = {
      $set: {
        "meshblu.tokens.#{hashedToken}": metadata
      }
    }
    @devices.update { uuid }, updateQuery, (error) =>
      return callback error if error?
      @tokens.remove { uuid, hashedToken }, callback

  _convertDevice: ({ uuid, meshblu }, callback) =>
    { tokens, createdAt }= meshblu
    newTokens = []
    _.each tokens, (metadata, hashedToken) =>
      metadata.createdAt ?= createdAt
      newTokens.push {
        uuid,
        hashedToken,
        metadata,
      }

    async.eachSeries newTokens, @_saveToken, (error) =>
      return callback error if error?
      @_removeFromDevice { uuid }, callback

  _saveToken: (tokenRecord, callback) =>
    @tokens.insert tokenRecord, callback

  _removeFromDevice: ({ uuid }, callback) =>
    query = { $unset: {  'meshblu.tokens': true }}
    @devices.update { uuid }, query, callback

module.exports = TokensMigration
