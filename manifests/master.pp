# Profile for the Puppet master node(s)
class profile::master {

  class{ '::avahi': }
  # Need to disallow other services
  file_line {'disallow_other_stacks_in_avahi':
    path    => '/etc/avahi/avahi-daemon.conf',
    line    => 'disallow-other-stacks=yes',
    match   => '#?disallow-other-stacks=(yes|no)',
    require => Package['avahi'],
    before  => Service['avahi-daemon'],
  }

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

  class { '::r10k': }
  ->

  ini_setting { 'modulepath':
    ensure  => absent,
    path    => '/etc/puppetlabs/puppet/puppet.conf',
    section => 'main',
    setting => 'modulepath',
  }
}
