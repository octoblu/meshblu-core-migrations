async = require 'async'

class MongoForEach
  constructor: ({ @collection, taskFn }) ->
    @queue = async.queue taskFn, 2

  do: (query={}, projection, callback) =>
    @cursor = @collection.find query, projection
    @cursor.count (error, count) =>
      return callback error if error?
      return callback new Error('Nothing found') unless count
      @cursor.forEach (error, task) =>
        return @_handleError error, callback if error?
        @queue.push task if task?

    @queue.drain = =>
      callback null

  _handleError: (error, callback) =>
    console.error 'error', error
    @cursor.destory()
    @queue.kill()
    callback error

module.exports = MongoForEach
