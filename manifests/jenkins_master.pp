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

  $private_key = hiera('profile::jenkins_master::private_key', undef)
  $public_key = hiera('profile::jenkins_master::public_key', undef)

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
    content => $private_key,
    require => File['/var/lib/jenkins/.ssh'],
  }

  # Jenkins RSA public key
  file { '/var/lib/jenkins/.ssh/id_rsa.pub':
    ensure  => file,
    mode    => '0644',
    owner   => 'jenkins',
    group   => 'jenkins',
    content => $public_key,
    require => File['/var/lib/jenkins/.ssh'],
  }
}
