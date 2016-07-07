_            = require 'lodash'
async        = require 'async'
MongoForEach = require '../helpers/mongo-for-each'

class DeviceTokensMigration
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
    callback new Error 'down not supported'

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

    async.eachSeries newTokens, @_saveToken, callback

  _saveToken: (tokenRecord, callback) =>
    @tokens.insert tokenRecord, callback

module.exports = DeviceTokensMigration
