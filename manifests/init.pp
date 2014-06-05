# The base profile - Likely need to be removed
# TODO: Make sure is needed
class profiles {
  # Create any defined hosts
  # create_resources('host', hiera('hosts'))

  host {'yum.azcender.com':
    ensure => 'present',
    ip     => '10.0.0.100',
  }

  # Set azcender yum repo
  yumrepo { 'azcender':
    name     => 'azcender',
    baseurl  => 'http://yum.azcender.com',
    enabled  => 1,
    gpgcheck => 0,
  }
}
