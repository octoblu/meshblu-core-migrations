_             = require 'lodash'
async         = require 'async'
mongoEach     = require 'mongo-each'
debug         = require('debug')('meshblu-core-migrations:mongo-for-each')
overviewDebug = require('debug')('meshblu-core-migrations:overview')

class MongoForEach
  constructor: ({ @collection, @parallel }) ->

  find: (query={}, projection) =>
    @cursor = @collection.find query, projection
    @cursor.limit(0)

  sort: (options) =>
    @cursor.sort options

  do: (iterator, callback) =>
    @cursor.count (error, @count) =>
      return callback error if error?
      overviewDebug 'found count', @count
      return callback new Error('Nothing found') unless @count
      mongoEach @cursor, { concurrency: 10 }, @_handleRecord(iterator), callback

  _handleRecord: (iterator) =>
    return (record, callback) =>
      return callback null unless record?
      { uuid, meshblu } = record
      tokensCount = _.size _.keys _.get(record, 'meshblu.tokens')
      overviewDebug "#{@count} -- starting #{uuid} - #{tokensCount}" if tokensCount > 10
      iterator record, callback

module.exports = MongoForEach
