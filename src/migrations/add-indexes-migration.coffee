_            = require 'lodash'
async        = require 'async'
debug        = require('debug')('meshblu-core-migrations:add-indexes')
MongoForEach = require '../helpers/mongo-for-each'

INDEXES={
  devices: [
    { uuid: -1 }
    { owner: -1 }
    { type: -1, owner: -1 }
    { socketid: -1 }
    { discoverWhitelist: -1 }
    { discoverAsWhitelist: -1 }
    { configureWhitelist: -1 }
    { configureAsWhitelist: -1 }
    { sendWhitelist: -1 }
    { sendAsWhitelist: -1 }
    { receiveWhitelist: -1 }
    { receiveAsWhitelist: -1 }
    { 'meshblu.whitelists.discover.uuid': -1 }
    { 'endo.idKey': -1 }
    { "20c10a9a-9396-4cb2-8bdd-d31736d6b919.id": -1 }
    { "2c0c3e1 0-c438-11e4-aa98-79da72ee4b62.id": -1 }
    { "47a22240-c43b-11e4-aa98-79da72ee4b62.id": -1 }
    { "7de108b0-c438-11e4-aa98-79da72ee4b62.id": -1 }
    { "8216e962-d90a-4ef6-8e73-aa1f9c65e393.id": -1 }
    { "93dcb760-b92d-11e4-8b0f-4dd97288647b.id": -1 }
    { "97174770-c43a-11e4-aa98-79da72ee4b62.id": -1 }
    { "da0ca1db-c4b6-468a-9f24-f53460307b5b.id": -1 }
    { "e545dc79-324a-4287-a47e-dacbb90a2fc0.id": -1 }
    { "ed353f60-c438-11e4-aa98-79da72ee4b62.id": -1 }
  ],
  # tokens: [
  #   { uuid: -1, hashedToken: -1 }
  #   { uuid: -1, 'metadata.tag': -1 }
  # ],
  # "delete-devices": [
  #   { uuid: -1 }
  # ],
  # subscriptions: [
  #   { subscriberUuid: -1 }
  #   { emitterUuid: -1, type: -1 }
  #   { subscriberUuid: -1, emitterUuid: -1, type: -1 }
  # ]
}

class AddIndexesMigration
  constructor: ({ @database }) ->
    @indexes = INDEXES

  up: (callback) =>
    console.log 'up'
    _.delay =>
      async.eachOfSeries @indexes, @addIndexes, callback
    , 2000

  addIndexes: (indexes, collection, callback) =>
    async.eachSeries indexes, async.apply(@addIndex, collection), callback

  addIndex: (collection, index, callback) =>
    console.log 'creating', { collection, index }
    @database.collection(collection).ensureIndex index, {background: true}, (error) =>
      _.delay callback, 1000, error

  down: (callback) =>
    callback new Error "down not supported, you probably meant to run 'add-indexes'"

module.exports = AddIndexesMigration
