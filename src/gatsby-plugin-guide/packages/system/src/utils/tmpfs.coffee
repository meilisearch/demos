
# parse the content of tmpfs daemon configuration file

string = require '@nikitajs/core/lib/utils/string'

module.exports =
  parse: (str) ->
    lines = string.lines str
    files = {}
    lines.forEach (line, _, __) ->
      return if not line or line.match(/^#.*$/)
      values = [type,mount,mode,uid,gid,age,argu] = line.split(/\s+/)
      obj = {}
      for i,key of ['type','mount','perm','uid','gid','age','argu']
        obj[key] = if values[i] isnt undefined then values[i] else '-'
        if i is "#{values.length-1}"
          files[mount] = obj if obj['mount']?
    files
  stringify: (obj) ->
    lines = []
    for k, v of obj
      for i,key of ['mount','perm','uid','gid','age','argu']
        v[key] = if v[key] isnt undefined then v[key] else '-'
      lines.push "#{v.type} #{v.mount} #{v.perm} #{v.uid} #{v.gid} #{v.age} #{v.argu}"
    lines.join '\n'
