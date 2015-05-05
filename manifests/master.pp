# Profile for the Puppet master node(s)
class profile::master {

  # Set global file settings
  file {'/etc/puppetlabs/puppet/modules':
    mode    => 'a+r',
    recurse => true
  }

  file { '/etc/puppetlabs/puppet/hiera.yaml':
    ensure => 'file',
    owner  => 'root',
    group  => 'root',
    mode   => '0755',
    source => 'puppet:///modules/profile/hiera.yaml',
    notify => Service['pe-httpd'],
  }

  file { '/etc/puppetlabs/r10k/r10k.yaml':
    ensure => 'file',
    owner  => 'root',
    group  => 'root',
    mode   => '0755',
    source => '/vagrant/puppet/r10k.yaml',
    notify => Service['pe-httpd'],
  }
}
