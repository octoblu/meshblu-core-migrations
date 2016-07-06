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

  _convertDevice: ({ uuid, meshblu, token }, callback) =>
    { tokens, createdAt }= meshblu
    newTokens = []
    _.each tokens, (metadata, hashedToken) =>
      newTokens.push {
        uuid,
        hashedToken,
        metadata,
      }
    async.eachSeries newTokens, @_saveToken, (error) =>
      return callback error if error?
      @_convertRootToken { uuid, token, createdAt }, (error) =>
        return callback error if error?
        @_removeFromDevice { uuid }, callback

  _convertRootToken: ({ uuid, token, createdAt }, callback) =>
    tokenRecord = {
      uuid,
      hashedRootToken: token,
      metadata: {
        createdAt
      }
    }
    @_saveToken tokenRecord, callback

  _saveToken: (tokenRecord, callback) =>
    @tokens.insert tokenRecord, callback

  _removeFromDevice: ({ uuid }, callback) =>
    query = { $unset: {  "meshblu.tokens": true, token: true }}
    @devices.update { uuid }, query, callback

module.exports = TokensMigration
