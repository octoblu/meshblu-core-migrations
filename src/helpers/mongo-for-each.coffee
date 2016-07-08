_     = require 'lodash'
async = require 'async'
debug = require('debug')('meshblu-core-migrations:mongo-for-each')
overviewDebug = require('debug')('meshblu-core-migrations:overview')

class MongoForEach
  constructor: ({ @collection }) ->

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
      async.timesSeries @count, @_handleRecord(iterator), callback

  _handleRecord: (iterator) =>
    return (n, callback) =>
      @cursor.next (error, record) =>
        return @_handleError error, callback if error?
        return callback null unless record?
        { uuid, meshblu } = record
        tokensCount = _.size _.keys _.get(record, 'meshblu.tokens')
        overviewDebug "#{n} / #{@count} -- starting #{uuid} - #{tokensCount}" if n % 10 == 0
        iterator record, (error) =>
          return @_handleError error, callback if error?
          overviewDebug "#{n} / #{@count} -- done with #{uuid}" if n % 10 == 0
          callback null

  _handleError: (error, callback) =>
    console.error 'error', error
    @cursor.destory()
    @queue.kill()
    callback error

module.exports = MongoForEach
