
nikita = require '@nikitajs/core/lib'
{tags, config} = require '../test'
they = require('mocha-they')(config)

return unless tags.posix

describe 'file.types.hfile', ->

  they 'without properties', ({ssh}) ->
    nikita
      $ssh: ssh
      $tmpdir: true
    , ({metadata: {tmpdir}}) ->
      {$status} = await @file.types.hfile
        target: "#{tmpdir}/empty.xml"
        content: {}
      $status.should.be.true()
      {$status} = await @file.types.hfile
        target: "#{tmpdir}/empty.xml"
        content: {}
      $status.should.be.false()
      @fs.assert
        target: "#{tmpdir}/empty.xml"
        content: """
        <?xml version=\"1.0\" encoding=\"UTF-8\"?>
        <configuration/>
        """.trim()

  they 'with properties', ({ssh}) ->
    nikita
      $ssh: ssh
      $tmpdir: true
    , ({metadata: {tmpdir}}) ->
      {$status} = await @file.types.hfile
        target: "#{tmpdir}/empty.xml"
        properties: a_key: 'a value'
      $status.should.be.true()
      {$status} = await @file.types.hfile
        target: "#{tmpdir}/empty.xml"
        properties: a_key: 'a value'
      $status.should.be.false()
      @fs.assert
        target: "#{tmpdir}/empty.xml"
        content: """
        <?xml version=\"1.0\" encoding=\"UTF-8\"?>
        <configuration>
          <property>
            <name>a_key</name>
            <value>a value</value>
          </property>
        </configuration>
        """.trim()

  they 'with source', ({ssh}) ->
    nikita
      $ssh: ssh
      $tmpdir: true
    , ({metadata: {tmpdir}}) ->
      @file
        target: "#{tmpdir}/empty.xml"
        content: """
        <?xml version=\"1.0\" encoding=\"UTF-8\"?>
        <configuration>
          <property>
            <name>a_key</name>
            <value>a value</value>
          </property>
        </configuration>
        """.trim()
      {$status} = await @file.types.hfile
        target: "#{tmpdir}/empty.xml"
        properties: a_key: 'a value'
        source: "#{tmpdir}/empty.xml"
      $status.should.be.false()
      {$status} = await @file.types.hfile
        target: "#{tmpdir}/empty.xml"
        properties: a_key: 'a new value'
        source: "#{tmpdir}/empty.xml"
      $status.should.be.true()
      {$status} = await @file.types.hfile
        target: "#{tmpdir}/empty.xml"
        properties: a_new_key: 'a value'
        source: "#{tmpdir}/empty.xml"
      $status.should.be.true()

  they 'transform', ({ssh}) ->
    nikita
      $ssh: ssh
      $tmpdir: true
    , ({metadata: {tmpdir}}) ->
      @file
        target: "#{tmpdir}/empty.xml"
        content: """
        <?xml version=\"1.0\" encoding=\"UTF-8\"?>
        <configuration>
          <property>
            <name>key_1</name>
            <value>value 1</value>
          </property>
        </configuration>
        """.trim()
      @file.types.hfile
        target: "#{tmpdir}/empty.xml"
        merge: true
        properties: key_2: 'value 2'
        transform: (props) ->
          newprops = {}
          for k, v of props
            newprops[k.toUpperCase()] = v
          newprops
      @fs.assert
        target: "#{tmpdir}/empty.xml"
        content: """
        <?xml version=\"1.0\" encoding=\"UTF-8\"?>
        <configuration>
          <property>
            <name>KEY_1</name>
            <value>value 1</value>
          </property>
          <property>
            <name>KEY_2</name>
            <value>value 2</value>
          </property>
        </configuration>
        """.trim()
