node 'base' {
  include ntp

  @@host { $::hostname:
    ensure         => present,
    ip             => $::virtual ? {
      'virtualbox' => $::ipaddress_eth1,
      default      => $::ipaddress_eth0,
    },
    host_aliases   => $hostname,
  }

  host { 'localhost':
    ensure       => present,
    ip           => '127.0.0.1',
    host_aliases => 'localhost.localdomain',
  }

  Host <<||>>
}

node /^master.*$/ inherits base {
  if $::osfamily == 'redhat' {
    class { 'firewall': ensure => stopped, }
  }

#  package { 'git': ensure => present, }

  # Simple decleration of zack/r10k
  class { 'r10k':
    remote                 => 'https://bitbucket.org/prolixalias/puppet-r10k-environments.git',
    include_prerun_command => true,
  }

  file { 'r10k environments dir':
    ensure   => directory,
    path     => '/etc/puppetlabs/puppet/environments',
  }

#  class { 'r10k':
#    version           => '1.2.1',
#
#    sources           => {
#      'puppet' => {
#        'remote'  => 'https://bitbucket.org/prolixalias/puppet-r10k-environments.git',
#        'basedir' => "${::settings::confdir}/environments",
#        'prefix'  => false,
#      },
#
#      'hiera' => {
#        'remote'  => 'https://bitbucket.org/prolixalias/puppet-r10k-hiera.git',
#        'basedir' => "${::settings::confdir}/hiera",
#        'prefix'  => true,
#      }
#    },
#
#    purgedirs         => ["${::settings::confdir}/environments"],
#    manage_modulepath => true,
#    modulepath        => "${::settings::confdir}/environments/\$environment/modules:/opt/puppet/share/puppet/modules",
#  }
#
#  exec { 'r10k deploy environment --puppetfile':
#    path     => ['/bin','/sbin','/usr/bin','/usr/sbin','/opt/puppet/bin'],
#    require  => [Package['git'],File['r10k environments dir'],Class['r10k::install']],
#  }
#
#  include r10k::prerun_command
#  include r10k::mcollective

  ini_setting { 'master module path':
    ensure   => present,
    path     => '/etc/puppetlabs/puppet/puppet.conf',
    section  => 'main',
    setting  => 'modulepath',
    value    => '/etc/puppetlabs/puppet/environments/$environment/modules:/opt/puppet/share/puppet/modules',
  }

  ini_setting { 'master manifest path':
    ensure   => present,
    path     => '/etc/puppetlabs/puppet/puppet.conf',
    section  => 'main',
    setting  => 'manifest',
    value    => '/etc/puppetlabs/puppet/environments/$environment/manifests/site.pp',
  }

# hiera.yaml is read only at master startup thus this will not work!
#  ini_setting { 'hiera path':
#    ensure  => present,
#    path    => '/etc/puppetlabs/puppet/puppet.conf',
#    section => 'main',
#    setting => 'hiera_config',
#    value   => '/etc/puppetlabs/puppet/environments/$environment/hiera.yaml',
#  }

  file { '/etc/puppetlabs/puppet/hiera.yaml':
    ensure   => file, mode => '0755', owner => 'root', group => 'root',
    source   => 'file:///vagrant/puppet/files/hiera.yaml',
    notify   => Service['pe-httpd'],
  }

  service { 'pe-httpd': ensure => running, }
}

node default inherits base {
  notify { "Node ${::hostname} received default node classification!": }
  file { '/tmp/runpuppet.sh':
    ensure   => 'file',
    mode     => '0755',
    owner    => 'root',
    group    => 'root',
    content  => "#!/bin/bash\npuppet agent -t",
  } -> exec { 'at now + 1 min -f /tmp/runpuppet.sh':
    path     => ['/bin', '/sbin', '/usr/bin', '/usr/sbin', '/opt/puppet/bin'],
  }
}
