
path = require 'path'

module.exports =
  ###
  Shell command to print archictecture, OS name, version release and linux
  version release to stdout.

  The `arch` property is obtained from `uname -m`. Note, on Apple M1, `uname -p`
  return `arm` when `uname -m` return `arm64`. See the [`uname` possible
  values](https://en.wikipedia.org/wiki/Uname#Examples).

  The `name` property return one of 'rhel', 'centos', 'ubuntu', 'debian' or
  'arch'. Other distributions are not yet implemented.

  TODO:
  - we shall implement a property `distrib` to distinguish `rhel` from `centos`
  - name shall return an array of possible match, eg CentOS 6 matching
    `centos6`, `centos`, `rhel`, `linux`. This way, the `if_os` condition will
    match against multiple keywords.

  The following distributions are supported and tested:
  * RHEL 6, CentOS 6
  * RHEL 7, CentOS 7
  * Ubuntu/Debian
  * Arch Linux
  * TODO: support RHEL 8, CentOS 8
  ###
  command: """
    #ARCH=$(uname -m | sed 's/x86_//;s/i[3-6]86/32/')
    ARCH=$(uname -m)
    LINUX_VERSION=`uname -r | sed 's/\\(.*\\)-.*/\\1/'`
    # RHEL 7 (CentOS 7), Ubuntu/Debian, Arch Linux
    if [ -f /etc/os-release ]; then
      DISTRIB=`cat /etc/os-release | egrep '^ID=' | sed 's/^\\(ID="\\?\\)\\?\\([A-Za-z]*\\).*/\\2/'`
    # RHEL 6 (CentOS 6)
    elif [ -f /etc/redhat-release ]; then
      DISTRIB=`cat /etc/redhat-release | sed 's/^\\(Red \\)\\?\\([A-Za-z]*\\).*/\\1\\2/' | tr '[:upper:]' '[:lower:]'`
      if [ $DISTRIB == 'red hat' ]; then
        DISTRIB='rhel'
      fi
    else
      exit 2
    fi
    case $DISTRIB in
      # RHEL and CentOS
      rhel|centos)
        # `cat /etc/redhat-release` prints for:
        #  - CentOS 6: 'CentOS release 6.10 (Final)'
        #  - CentOS 7: 'CentOS Linux release 7.9.2009 (Core)'
        #  - RHEL 6: 'Red Hat Enterprise Linux Server release 6.4 (Santiago)'
        #  - RHEL 7: 'Red Hat Enterprise Linux Server release 7.0 (Maipo)'
        VERSION=`cat /etc/redhat-release | sed 's/.* \\([0-9]\\)\\(\\(\\.*[0-9]\\)*\\) .*/\\1\\2/'`
        ;;
      # Ubuntu
      ubuntu)
        . /etc/lsb-release
        VERSION=$DISTRIB_RELEASE
        ;;
      # Debian
      debian)
        VERSION=`cat /etc/debian_version`
        ;;
      # Arch Linux
      arch)
        VERSION=''
        ;;
      *)
        exit 2
    esac
    echo -n "$ARCH|$DISTRIB|$VERSION|$LINUX_VERSION"
    """
  whoami: ({ssh, platform = process.platform} = {}) ->
    return ssh.config.username if ssh
    return process.env['USERPROFILE'].split(path.win32.sep)[2] if /^win/.test platform
    return process.env['USER'] if process.env['USER']
    return process.env['HOME'].split('/')[1] if /^\/root$/.test process.env['HOME']
    return process.env['HOME'].split('/')[2] if /^\/home\/[^\/]+$/.test process.env['HOME']
