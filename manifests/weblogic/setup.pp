# test
#
# one machine setup with weblogic 10.3.6 with BSU
# needs jdk7, orawls, orautils, fiddyspence-sysctl, erwbgy-limits puppet modules
#

class profile::weblogic::setup (
  $augeas,
  $files,
) {
  # Execute augesus for weblogic
  create_resources(augeas, $augeas)

  # Create file resources
  create_resources(file, $files)

  # Create a software directory for install files
  file { '/software':
    ensure => directory,
  }

  # Fetch install media from a download location
  # TODO: Move to organization specific location
  wget::fetch { 'UnlimitedJCEPolicyJDK7':
    source      => 'http://artifactory.azcender.com/artifactory/application-deploys/com/oracle/UnlimitedJCEPolicyJDK7/7.0.0/UnlimitedJCEPolicyJDK7-7.0.0.zip',
    destination => '/software/UnlimitedJCEPolicyJDK7.zip',
    require     => File['/software'],
  }

  wget::fetch { 'JDK7':
    source      => 'http://artifactory.azcender.com/artifactory/application-deploys/com/oracle/jdk/7u55/jdk-7u55-linux-x64.tar.gz',
    destination => '/software/jdk-7u55-linux-x64.tar.gz',
    require     => File['/software'],
  }


  wget::fetch { 'wls1036_generic.jar':
    source      => 'http://artifactory.azcender.com/artifactory/ext-release-local/com/oracle/wls1036_generic/10.3.6/wls1036_generic-10.3.6.jar',
    destination => '/software/wls1036_generic.jar',
    require     => File['/software'],
  }
}
