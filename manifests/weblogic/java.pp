# test
#
# one machine setup with weblogic 10.3.6 with BSU
# needs jdk7, orawls, orautils, fiddyspence-sysctl, erwbgy-limits puppet modules
#

class profile::weblogic::java {
  # Remove any openjdk files
  $remove = [ 'java-1.7.0-openjdk.x86_64', 'java-1.6.0-openjdk.x86_64' ]

  package { $remove:
    ensure  => absent,
  }

  # TODO: Move jdk version to Hiera
  $java_version = 'jdk1.7.0_55'

  # Instdall JDK 7
  jdk7::install7{ $java_version :
    version                   => '7u55' ,
    fullVersion               => $java_version,
    alternativesPriority      => 18000,
    x64                       => true,
    downloadDir               => '/var/tmp/install',
    urandomJavaFix            => true,
    rsakeySizeFix             => true,
    cryptographyExtensionFile => 'UnlimitedJCEPolicyJDK7.zip',
    sourcePath                => '/software',
    require                   => Class['wget']
  }
}
