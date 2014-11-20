# A wrapper that contains all thr functionality needed for a standard java web
# application --- does not support JEE applications

class profile::jenkins_master {
  # Include base class
  include ::profile

  # Include standard jenkins class
  include ::jenkins
  include ::jenkins::master

  # The FS Jenkins requires a git executable
  include ::git

  # Ensure the private and public key are installed in home

  # Jenkins SSH directory
  file { '/var/lib/jenkins/.ssh':
    ensure  => directory,
    mode    => '0700',
    owner   => 'jenkins',
    group   => 'jenkins',
    require => User['jenkins'],
  }

  # Jenkins RSA private key
  file { '/var/lib/jenkins/.ssh/id_rsa':
    ensure  => file,
    mode    => '0600',
    owner   => 'jenkins',
    group   => 'jenkins',
    require => File['/var/lib/jenkins/.ssh'],
  }

  # Jenkins RSA public key
  file { '/var/lib/jenkins/.ssh/id_rsa.pub':
    ensure  => file,
    mode    => '0644',
    owner   => 'jenkins',
    group   => 'jenkins',
    require => File['/var/lib/jenkins/.ssh'],
  }
}
