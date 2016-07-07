_          = require 'lodash'
colors     = require 'colors'
dashdash   = require 'dashdash'
migrations = require './src/migrations'

OPTIONS = [
  {
    names: ['help', 'h']
    type: 'bool'
    help: 'Print this help'
  },
]

class CommandList
  constructor: (@argv) ->
    @parser = dashdash.createParser options: OPTIONS

  getOpts: =>
    {help} = @parser.parse @argv

    @printHelp {help} if help

    return {}

  fatalError: (error) =>
    console.error error.stack
    process.exit 1

  fatalMessage: (message) =>
    console.error colors.red message
    process.exit 1

  printHelp: ({help, name, mongodb_uri}) =>
    console.log "usage: ./command-list.js [options]\n"
    console.log "options:\n"
    console.log @parser.help {includeEnv: true}
    process.exit 0 if help
    process.exit 1

  run: =>
    names = _.keys migrations
    return console.error colors.red 'No migrations' if _.isEmpty migrations
    _.each names, (name) =>
      console.log name

module.exports = CommandList
