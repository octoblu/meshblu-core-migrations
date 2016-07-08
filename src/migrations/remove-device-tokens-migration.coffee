_            = require 'lodash'
async        = require 'async'
MongoForEach = require '../helpers/mongo-for-each'

class RemoveDeviceTokensMigration
  constructor: ({ @database }) ->
    @devices = @database.collection 'devices'
    @tokens = @database.collection 'tokens'

  up: (callback) =>
    query = { 'meshblu.tokens': { $gt: {} } }
    projection = { uuid: true, 'meshblu': true, token: true }
    updateQuery = { $unset: {  'meshblu.tokens': true }}

    bulk = @devices.initializeUnorderedBulkOp()
    find = bulk.find query, projection
    find.upsert().update(updateQuery)
    bulk.execute callback

  down: (callback) =>
    query = { 'uuid': $exists: true }
    @database._getConnection (error, db) =>
      return callback error if error?
      collection = db.collection('tokens')
      mongoForEach = new MongoForEach({ collection })
      mongoForEach.find query, { _id: false }
      mongoForEach.do @_revertFromToken, callback

  _revertFromToken: ({ uuid, hashedToken, metadata }, callback) =>
    updateQuery = {
      $set: {
        "meshblu.tokens.#{hashedToken}": metadata
      }
    }
    @devices.update { uuid }, updateQuery, (error) =>
      return callback error if error?
      @tokens.remove { uuid, hashedToken }, callback

module.exports = RemoveDeviceTokensMigration
