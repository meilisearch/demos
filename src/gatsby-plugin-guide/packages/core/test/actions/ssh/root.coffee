
connect = require 'ssh2-connect'
nikita = require '../../../src'
utils = require '../../../src/utils'
{tags, config} = require '../../test'
# All test are executed with an ssh connection passed as an argument
they = require('mocha-they')(config.filter ({ssh}) -> !!ssh)

return unless tags.posix

describe 'actions.ssh.root', ->
  
  describe 'schema', ->
    
    they 'config.selinux is invalid', ({ssh}) ->
      nikita
      .ssh.root
        selinux: '_invalid_'
      ,
        ssh
      .should.be.rejectedWith
        code: 'NIKITA_SCHEMA_VALIDATION_CONFIG'
        message: [
          'NIKITA_SCHEMA_VALIDATION_CONFIG: multiple errors were found in the configuration of action `ssh.root`:'
          '#/definitions/config/properties/selinux/oneOf config/selinux must match exactly one schema in oneOf, passingSchemas is null;'
          '#/definitions/config/properties/selinux/oneOf/0/enum config/selinux must be equal to one of the allowed values, allowedValues is ["disabled","enforcing","permissive"];'
          '#/definitions/config/properties/selinux/oneOf/1/type config/selinux must be boolean, type is "boolean".'
        ].join ' '
          
    they 'config.selinux is valid', ({ssh}) ->
      nikita
      .ssh.root
        $dry: true
        selinux: 'permissive'
      , ssh
      .should.be.finally.containEql $status: false
