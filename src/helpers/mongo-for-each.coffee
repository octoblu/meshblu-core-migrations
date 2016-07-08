_     = require 'lodash'
async = require 'async'
debug = require('debug')('meshblu-core-migrations:mongo-for-each')

class MongoForEach
  constructor: ({ @collection }) ->

  find: (query={}, projection) =>
    @cursor = @collection.find query, projection
    @cursor.limit(0)

  do: (iterator, callback) =>
    @cursor.count (error, count) =>
      return callback error if error?
      debug 'found count', count
      return callback new Error('Nothing found') unless count
      async.timesSeries count, @_handleRecord(iterator), callback

  _handleRecord: (iterator) =>
    return (n, callback) =>
      debug 'getting next', n
      @cursor.next (error, record) =>
        return @_handleError error, callback if error?
        return callback null unless record?
        debug 'pushing', { uuid: record.uuid }
        iterator record, callback

  _handleError: (error, callback) =>
    console.error 'error', error
    @cursor.destory()
    @queue.kill()
    callback error

module.exports = MongoForEach
