colors     = require 'colors'
dashdash   = require 'dashdash'
mongojs    = require 'mongojs'
migrations = require './src/migrations'

OPTIONS = [
  {
    names: ['help', 'h']
    type: 'bool'
    help: 'Print this help'
  },
  {
    names: ['mongodb-uri', 'm']
    type: 'string'
    help: 'Mongo DB URI'
    env: 'MIGRATIONS_MONGODB_URI'
  },
  {
    names: ['name', 'n']
    type: 'string'
    help: 'The name of the migration to run'
    env: 'MIGRATIONS_NAME'
  },
]

class RunMigration
  constructor: (@argv) ->
    @parser = dashdash.createParser options: OPTIONS

  getOpts: =>
    {help, mongodb_uri, name} = @parser.parse @argv

    @printHelp {help} if help
    @printHelp {mongodb_uri, name} unless mongodb_uri
    @printHelp {name, mongodb_uri} unless name

    return {mongodb_uri, name}

  fatalError: (error) =>
    console.error error.stack
    process.exit 1

  fatalMessage: (message) =>
    console.error colors.red message
    process.exit 1

  printHelp: ({help, name, mongodb_uri}) =>
    console.log "usage: ./command-down.js [options]\n"
    console.log "options:\n"
    console.log @parser.help {includeEnv: true}
    process.exit 0 if help

    console.log colors.red '  -m, --mongodb-uri is required' unless mongodb_uri
    console.log colors.red '  -n, --name is required' unless name
    process.exit 1

  run: =>
    {mongodb_uri, name} = @getOpts()
    database = mongojs mongodb_uri
    Migration = migrations[name]
    @fatalMessage "Invalid Migration #{name}" unless Migration?
    migration = new Migration {database}
    migration.down (error) =>
      @fatalError error if error?
      console.log colors.green 'it has been done'
      process.exit 0

module.exports = RunMigration
