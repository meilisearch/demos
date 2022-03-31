
nikita = require '@nikitajs/core/lib'
{tags, config} = require '../test'
they = require('mocha-they')(config)

return unless tags.posix

describe 'file.types.ssh_authorized_keys', ->

  they 'overwrite file', ({ssh}) ->
    nikita
      $ssh: ssh
      $tmpdir: true
    , ({metadata: {tmpdir}}) ->
      @file
        target: "#{tmpdir}/authorized_keys"
        content: "# Some Comment"
      {$status} = await @file.types.ssh_authorized_keys
        target: "#{tmpdir}/authorized_keys"
        keys: [
          'ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQCgccoXaSKaovgSkExo09Vv6PJmJEjIwrD+MQTLUQrhM6dSCQ40KNJkLATsrm3p14QGzT2G5IiIUVfl/dwXUS5kqOKRYJUBl5o1ETzxWCUzWUcaY7JmrAlQwQgBMwtwv/ClpYqjiHwGcoMOuobumXfsyz7f3CuqvrldQEfcv/f0u7t/78nVceDE4mjlMGH/bwyzH09CYHPnLW9S/Jvhw5hbyCTDDqheCZHb+Y3xecRV+fGDfH7onn/FWu9JRj0UWkzGZoCp8Lj5hZ/mAF2fqH5tbW36DkC66zi3jJNI2cwARHxH1TQ8DeDKnUjaY7J03CbB+RIaKh5KjbEquqWlTQSP Some Description'
        ]
      $status.should.be.true()
      @fs.assert
        target: "#{tmpdir}/authorized_keys"
        content: "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQCgccoXaSKaovgSkExo09Vv6PJmJEjIwrD+MQTLUQrhM6dSCQ40KNJkLATsrm3p14QGzT2G5IiIUVfl/dwXUS5kqOKRYJUBl5o1ETzxWCUzWUcaY7JmrAlQwQgBMwtwv/ClpYqjiHwGcoMOuobumXfsyz7f3CuqvrldQEfcv/f0u7t/78nVceDE4mjlMGH/bwyzH09CYHPnLW9S/Jvhw5hbyCTDDqheCZHb+Y3xecRV+fGDfH7onn/FWu9JRj0UWkzGZoCp8Lj5hZ/mAF2fqH5tbW36DkC66zi3jJNI2cwARHxH1TQ8DeDKnUjaY7J03CbB+RIaKh5KjbEquqWlTQSP Some Description\n"

  they 'merge file', ({ssh}) ->
    nikita
      $ssh: ssh
      $tmpdir: true
    , ({metadata: {tmpdir}}) ->
      @file
        target: "#{tmpdir}/authorized_keys"
        content: "# Some Comment"
      {$status} = await @file.types.ssh_authorized_keys
        target: "#{tmpdir}/authorized_keys"
        keys: [
          'ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQCgccoXaSKaovgSkExo09Vv6PJmJEjIwrD+MQTLUQrhM6dSCQ40KNJkLATsrm3p14QGzT2G5IiIUVfl/dwXUS5kqOKRYJUBl5o1ETzxWCUzWUcaY7JmrAlQwQgBMwtwv/ClpYqjiHwGcoMOuobumXfsyz7f3CuqvrldQEfcv/f0u7t/78nVceDE4mjlMGH/bwyzH09CYHPnLW9S/Jvhw5hbyCTDDqheCZHb+Y3xecRV+fGDfH7onn/FWu9JRj0UWkzGZoCp8Lj5hZ/mAF2fqH5tbW36DkC66zi3jJNI2cwARHxH1TQ8DeDKnUjaY7J03CbB+RIaKh5KjbEquqWlTQSP Some Description'
        ]
        merge: true
      $status.should.be.true()
      @fs.assert
        target: "#{tmpdir}/authorized_keys"
        content: """
        # Some Comment
        ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQCgccoXaSKaovgSkExo09Vv6PJmJEjIwrD+MQTLUQrhM6dSCQ40KNJkLATsrm3p14QGzT2G5IiIUVfl/dwXUS5kqOKRYJUBl5o1ETzxWCUzWUcaY7JmrAlQwQgBMwtwv/ClpYqjiHwGcoMOuobumXfsyz7f3CuqvrldQEfcv/f0u7t/78nVceDE4mjlMGH/bwyzH09CYHPnLW9S/Jvhw5hbyCTDDqheCZHb+Y3xecRV+fGDfH7onn/FWu9JRj0UWkzGZoCp8Lj5hZ/mAF2fqH5tbW36DkC66zi3jJNI2cwARHxH1TQ8DeDKnUjaY7J03CbB+RIaKh5KjbEquqWlTQSP Some Description\n
        """
