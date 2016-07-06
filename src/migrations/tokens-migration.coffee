_     = require 'lodash'
async =  require 'async'

class TokensMigration
  constructor: ({ datastores }) ->
    { @devices, @tokens } = datastores

  up: (callback) =>
    query = { 'meshblu.tokens': $exists: true }
    @devices.find query, (error, devices) =>
      async.eachSeries devices, @_convertDevice, callback

  down: (callback) =>
    callback()

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
