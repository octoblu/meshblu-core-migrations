_            = require 'lodash'
async        = require 'async'
{ ObjectId } = require 'mongojs'
overviewDebug = require('debug')('meshblu-core-migrations:overview')
MongoForEach = require '../helpers/mongo-for-each'

class RemoveDuplicateTokens
  constructor: ({ @database }) ->
    @tokens = @database.collection 'tokens'

  up: (callback) =>
    query = [
      {
        $group: {
          _id: { uuid: '$uuid', hashedToken: '$hashedToken' },
          uniqueIds: { $addToSet: '$_id' },
          count: { $sum: 1 }
        }
      },
      { $sort : { count : -1 } }
      {
        $match: {
          count: { $gt: 1 }
        }
      }
    ]
    @tokens.aggregate query, {
      allowDiskUse:true,
      cursor:{}
    }, (error, results) =>
      return callback error if error?
      overviewDebug 'found results', { length: results.length }
      async.eachSeries results, @_delayRemoveDups, callback

  _delayRemoveDups: ({uniqueIds, _id}, callback) =>
    _.delay @_removeDuplicates, 100, {uniqueIds, _id}, callback

  _removeDuplicates: ({uniqueIds, _id}, callback) =>
    overviewDebug 'removing dups', _id
    deleteThese = _.tail uniqueIds
    @tokens.remove { _id: { $in: deleteThese } }, callback

  down: (callback) =>
    callback new Error 'down not supported'

module.exports = RemoveDuplicateTokens
