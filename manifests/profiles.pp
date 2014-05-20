class profiles {
  # Create any defined hosts
  # create_resources('host', hiera('hosts'))

  # Set azcender yum repo
  yumrepo { 'azcender':
    baseurl => 'http://yum.azcender.com',
    enabled => 1,
    gpgcheck => 0,
  }
}
