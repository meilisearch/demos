
utils = require '@nikitajs/core/lib/utils'

module.exports =
  parse: (str) ->
    lines = utils.string.lines str
    list_of_mount_sections = []
    list_of_group_sections = {}
    # variable which hold the cursor position
    current_mount = false
    current_group = false
    current_group_name = ''
    current_group_controller = false
    current_group_perm = false
    current_group_perm_content = false
    current_default = false
    # variables which hold the data
    current_mount_section = null
    current_group_section = null # group section is a tree but only of group
    current_controller_name = null
    current_group_section_perm_name = null
    lines.forEach (line, _, __) ->
      return if not line or line.match(/^\s*$/)
      if !current_mount and !current_group and !current_default
        if /^mount\s{$/.test line # start of a mount object
          current_mount = true
          current_mount_section = []
        if /^(group)\s([A-z|0-9|\/]*)\s{$/.test line # start of a group object
          current_group = true
          match = /^(group)\s([A-z|0-9|\/]*)\s{$/.exec line
          current_group_name = match[2]
          current_group_section = {}
          list_of_group_sections["#{current_group_name}"] ?= {}
        if /^(default)\s{$/.test line # start of a special group object named default
          current_group = true
          current_group_name = ''
          current_group_section = {}
          list_of_group_sections["#{current_group_name}"] ?= {}
      else
        # we are parsing a mount object
        # ^(cpuset|cpu|cpuacct|memory|devices|freezer|net_cls|blkio)\s=\s[aA-zZ|\s]*
        if current_mount
          if /^}$/.test line # close the mount object
            list_of_mount_sections.push current_mount_section...
            current_mount = false
            current_mount_section = []
          # add the line to mont object
          else
            line = line.replace ';',''
            sep = '='
            sep = ':' if line.indexOf(':') isnt -1
            line = line.split sep
            current_mount_section.push type: "#{line[0].trim()}", path:"#{line[1].trim()}"
        # we are parsing a group object
        # ^(cpuset|cpu|cpuacct|memory|devices|freezer|net_cls|blkio)\s=\s[aA-zZ|\s]*
        if current_group
          # if a closing bracket is encountered, it should set the cursor to false
          if /^(\s*)?}$/.test line
            if current_group
              if current_group_controller
                current_group_controller = false
              else if current_group_perm
                if current_group_perm_content
                  current_group_perm_content = false
                else
                  current_group_perm = false
              else
                current_group = false
                # push the group if the closing bracket is closing a group
                # list_of_group_sections["#{current_group_name}"] = current_group_section
                current_group_section = null
            #closing the group object
          else
            match = /^\s*(cpuset|cpu|cpuacct|blkio|memory|devices|freezer|net_cls|perf_event|net_prio|hugetlb|pids|rdma)\s{$/.exec line
            # currently reading a group config
            if !current_group_perm and !current_group_controller
              #if neither working in perm or controller section, we are declaring one of them
              if /^\s*perm\s{$/.test line # perm declaration
                current_group_perm =  true
                current_group_section['perm'] = {}
                list_of_group_sections["#{current_group_name}"]['perm'] = {}
              if match #controller declaration
                current_group_controller =  true
                current_controller_name = match[1]
                current_group_section["#{current_controller_name}"] = {}
                list_of_group_sections["#{current_group_name}"]["#{current_controller_name}"] ?= {}
            else if current_group_perm and current_group_perm_content# perm config
              line = line.replace ';',''
              line = line.split('=')
              [type,value] = line
              current_group_section['perm'][current_group_section_perm_name][type.trim()] = value.trim()
              list_of_group_sections["#{current_group_name}"]['perm'][current_group_section_perm_name][type.trim()] = value.trim()
            else if current_group_controller # controller config
              line = line.replace ';',''
              sep = '='
              sep = ':' if line.indexOf(':') isnt -1
              line = line.split sep
              [type, value] = line
              list_of_group_sections["#{current_group_name}"]["#{current_controller_name}"][type.trim()] ?= value.trim()
            else
              match_admin = /^\s*(admin|task)\s{$/.exec line
              if match_admin # admin or task declaration
                [_,name] = match_admin #the name is either admin or task
                current_group_perm_content = true
                current_group_section_perm_name = name
                current_group_section['perm'][name] = {}
                list_of_group_sections["#{current_group_name}"]['perm'][name] =  {}
    mounts: list_of_mount_sections, groups: list_of_group_sections
  stringify: (obj, config={}) ->
    obj.mounts ?= []
    obj.groups ?= {}
    render = ""
    config.indent ?= 2
    indent = ''
    indent += ' ' for i in [1..config.indent]
    sections = []
    if obj.mounts.length isnt 0
      mount_render = "mount {\n"
      for mount,k in obj.mounts
        mount_render += "#{indent}#{mount.type} = #{mount.path};\n"
      mount_render += '}'
      sections.push mount_render
    count = 0
    for name, group of obj.groups
      group_render = if (name is '') or (name is 'default') then 'default {\n' else "group #{name} {\n"
      for key, value of group
        if key is 'perm'
          group_render += "#{indent}perm {\n"
          if value['admin']?
            group_render += "#{indent}#{indent}admin {\n"
            group_render += "#{indent}#{indent}#{indent}#{prop} = #{val};\n" for prop, val of value['admin']
            group_render += "#{indent}#{indent}}\n"
          if value['task']?
            group_render += "#{indent}#{indent}task {\n"
            group_render += "#{indent}#{indent}#{indent}#{prop} = #{val};\n" for prop, val of value['task']
            group_render += "#{indent}#{indent}}\n"
          group_render += "#{indent}}\n"
        else
          group_render += "#{indent}#{key} {\n"
          group_render += "#{indent}#{indent}#{prop} = #{val};\n" for prop, val of value
          group_render += "#{indent}}\n"
      group_render += '}'
      count++
      sections.push group_render
    sections.join "\n"
