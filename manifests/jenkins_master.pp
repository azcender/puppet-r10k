# A wrapper class that install a jenkins master server. Includes the base
# profile and some additional configuration.
#
class profile::jenkins_master(
  $private_key = undef,
  $public_key  = undef,
) {
  # Include base class
  include ::profile

  # Include standard jenkins class
  include ::jenkins
  include ::jenkins::master

  # The FS Jenkins requires a git executable
  include ::git

  # If the public nd private key are defined then set them in the jenkins user
  # .ssh directory
  if $public_key  != undef and
     $private_key != undef {

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
}
