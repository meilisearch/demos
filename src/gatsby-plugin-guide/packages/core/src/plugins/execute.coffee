
{merge} = require 'mixme'
session = require '../session'

module.exports =
  name: '@nikitajs/core/src/plugins/execute'
  require: [
    '@nikitajs/core/src/plugins/tools/find'
    '@nikitajs/core/src/plugins/tools/walk'
  ]
  hooks:
    'nikita:action':
      handler: ({config, metadata, tools: {find, walk}}) ->
        return unless metadata.module is '@nikitajs/core/src/actions/execute'
        config.arch_chroot ?= await find ({metadata: {arch_chroot}}) -> arch_chroot
        config.arch_chroot_rootdir ?= await find ({metadata: {arch_chroot_rootdir}}) -> arch_chroot_rootdir
        config.bash ?= await find ({metadata: {bash}}) -> bash
        config.dry ?= await find ({metadata: {dry}}) -> dry
        env = merge config.env, ...await walk ({metadata: {env}}) -> env
        config.env = env if Object.keys(env).length
        config.env_export ?= await find ({metadata: {env_export}}) -> env_export
        config.sudo ?= await find ({metadata: {sudo}}) -> sudo
        
