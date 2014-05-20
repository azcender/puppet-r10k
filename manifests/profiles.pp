class profiles {
  # Create any defined hosts
  # create_resources('host', hiera('hosts'))

  host {'yum.azcender.com':
    ip     => '10.0.0.100',
    ensure => 'present',
  }

  # Set azcender yum repo
  yumrepo { 'azcender':
    name     => 'azcender',
    baseurl  => 'http://yum.azcender.com',
    enabled  => 1,
    gpgcheck => 0,
  }
}
