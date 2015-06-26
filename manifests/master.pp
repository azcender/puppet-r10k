# Profile for the Puppet master node(s)
#

class profile::master {
  # Set global file settings
  #file {'/etc/puppetlabs/puppet/modules':
  #  mode    => 'a+r',
  #  recurse => true
  #}

  file { '/etc/puppetlabs/puppet/hiera.yaml':
    ensure => 'file',
    owner  => 'root',
    group  => 'root',
    mode   => '0755',
    source => 'puppet:///modules/profile/hiera.yaml',
    #notify => Service['pe-puppetserver'],
  }

  file { '/opt/puppet/share/augeas/lenses/dist/sudoers2.aug':
    ensure => 'file',
    owner  => 'root',
    group  => 'root',
    mode   => '0755',
    source => 'puppet:///modules/profile/oracle/sudoers2.aug',
    #notify => Service['pe-puppetserver'],
  }

  #  ini_setting { 'modulepath':
  #  ensure  => absent,
  #  path    => '/etc/puppetlabs/puppet/puppet.conf',
  #  section => 'main',
  #  setting => 'modulepath',
  #}
}
