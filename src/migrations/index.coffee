module.exports = {
  'device-tokens': require './device-tokens-migration'
  'remove-device-tokens': require './remove-device-tokens-migration'
  'remove-duplicate-tokens': require './remove-duplicate-tokens-migration'
  'remove-expired-tokens': require './remove-expired-tokens-migration'
}
