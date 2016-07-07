_            = require 'lodash'
async        = require 'async'
MongoForEach = require '../helpers/mongo-for-each'

class RemoveDeviceTokensMigration
  constructor: ({ database }) ->
    @devices = database.collection 'devices'
    @tokens = database.collection 'tokens'

  up: (callback) =>
    query = { 'meshblu.tokens': $exists: true }
    projection = { uuid: true, 'meshblu': true, token: true }

    mongoForEach = new MongoForEach({ collection: @devices, taskFn: @_removeFromDevice })
    mongoForEach.do query, projection, callback

  down: (callback) =>
    query = { 'uuid': $exists: true }
    mongoForEach = new MongoForEach({ collection: @tokens, taskFn: @_revertFromToken })
    mongoForEach.do query, { _id: false }, callback

  _revertFromToken: ({ uuid, hashedToken, metadata }, callback) =>
    updateQuery = {
      $set: {
        "meshblu.tokens.#{hashedToken}": metadata
      }
    }
    @devices.update { uuid }, updateQuery, (error) =>
      return callback error if error?
      @tokens.remove { uuid, hashedToken }, callback

  _removeFromDevice: ({ uuid }, callback) =>
    query = { $unset: {  'meshblu.tokens': true }}
    @devices.update { uuid }, query, callback

module.exports = RemoveDeviceTokensMigration
