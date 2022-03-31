
// Register actions from Nikita packages
require('@nikitajs/db/lib/register')
require('@nikitajs/docker/lib/register')
require('@nikitajs/file/lib/register')
require('@nikitajs/ipa/lib/register')
require('@nikitajs/java/lib/register')
require('@nikitajs/krb5/lib/register')
require('@nikitajs/ldap/lib/register')
require('@nikitajs/log/lib/register')
require('@nikitajs/lxd/lib/register')
require('@nikitajs/network/lib/register')
require('@nikitajs/service/lib/register')
require('@nikitajs/system/lib/register')
require('@nikitajs/tools/lib/register')
// Expose the Nikita core engine
module.exports = require('@nikitajs/core')
