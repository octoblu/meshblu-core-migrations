_            = require 'lodash'
async        = require 'async'
debug        = require('debug')('meshblu-core-migrations:device-tokens')
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

      mongoForEach = new MongoForEach({ collection: @devices })
      mongoForEach.find query, projection
      mongoForEach.sort { _id: -1 }
      mongoForEach.do @_convertDevice, callback

  down: (callback) =>
    callback new Error 'down not supported'

  _convertDevice: ({ uuid, meshblu }, callback) =>
    debug "converting device #{uuid}", callback
    { tokens, createdAt }= meshblu
    newTokens = []
    _.each tokens, (metadata, hashedToken) =>
      metadata.createdAt ?= createdAt
      newTokens.push {
        uuid,
        hashedToken,
        metadata,
      }
    debug "#{uuid} has #{newTokens.length} tokens"
    return callback null if _.isEmpty newTokens
    async.eachSeries newTokens, @_saveToken, (error) =>
      debug "converted device #{uuid}", { error }
      return callback error if error?
      callback null

  _saveToken: (tokenRecord, callback) =>
    { uuid, hashedToken } = tokenRecord
    projection = { uuid: true }
    query = { uuid, hashedToken }
    options = { upsert: true, multi: true }
    @tokens.update query, { $set: tokenRecord }, options, callback

module.exports = DeviceTokensMigration
