module.exports = {
  'device-tokens': require './device-tokens-migration'
  'add-indexes': require './add-indexes-migration'
  'remove-device-tokens': require './remove-device-tokens-migration'
  'remove-duplicate-tokens': require './remove-duplicate-tokens-migration'
  'remove-expired-tokens': require './remove-expired-tokens-migration'
}
