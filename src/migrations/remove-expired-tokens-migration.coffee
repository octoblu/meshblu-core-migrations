_            = require 'lodash'
async        = require 'async'
{ ObjectId } = require 'mongojs'
overviewDebug = require('debug')('meshblu-core-migrations:overview')
MongoForEach = require '../helpers/mongo-for-each'

class RemoveExpiredTokens
  constructor: ({ @database }) ->
    @tokens = @database.collection 'tokens'

  up: (callback) =>
    overviewDebug 'going up'
    query = { expiresOn: { $exists: true, $lt: new Date() }}
    projection = { uuid: true }
    bulk = @tokens.initializeUnorderedBulkOp()
    find = bulk.find query, projection
    find.remove()
    bulk.execute callback

  down: (callback) =>
    callback new Error 'down not supported'

module.exports = RemoveExpiredTokens
