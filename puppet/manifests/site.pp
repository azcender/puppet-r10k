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

  file { 'r10k hiera dir':
    ensure   => directory,
    path     => '/etc/puppetlabs/puppet/hiera',
    mode     => 'og+rw',
    owner    => 'pe-puppet',
    group    => 'pe-puppet',
    recurse  => true,
  }

  file { 'r10k environments dir':
    ensure   => directory,
    path     => '/etc/puppetlabs/puppet/environments',
    mode     => 'og+rw',
    owner    => 'pe-puppet',
    group    => 'pe-puppet',
    recurse  => true,
  }

  class { 'r10k':
    sources           => {
      'puppet' => {
        'remote'  => 'https://bitbucket.org/prolixalias/puppet-r10k-environments.git',
        'basedir' => "${::settings::confdir}/environments",
        'prefix'  => false,
      },

      'hiera' => {
        'remote'  => 'https://bitbucket.org/prolixalias/puppet-r10k-hiera.git',
        'basedir' => "${::settings::confdir}/hiera",
        'prefix'  => true,
      }
    },

    purgedirs         => ["${::settings::confdir}/environments"],
    manage_modulepath => true,
    modulepath        => "${::settings::confdir}/environments/\$environment/modules:/opt/puppet/share/puppet/modules",
  } ->

  file { 'ruby spec directory':
    path    => '/opt/puppet/lib/ruby/gems/1.9.1/specifications',
    mode    => 'a+r',
    recurse  => true,
  } ->

  exec { 'r10k deploy environment --puppetfile':
    path     => ['/bin','/sbin','/usr/bin','/usr/sbin','/opt/puppet/bin'],
    require  => [Package['git'],File['r10k environments dir'],File['r10k hiera dir'],Class['r10k::install'],File['ruby spec directory']],
    timeout  => 0,
  } ->

  ini_setting { 'master manifest path':
    ensure   => present,
    path     => '/etc/puppetlabs/puppet/puppet.conf',
    section  => 'main',
    setting  => 'manifest',
    value    => '/etc/puppetlabs/puppet/environments/$environment/manifests/site.pp',
  }

  file { '/etc/puppetlabs/puppet/hiera.yaml':
    ensure => 'file',
    owner  => 'root',
    group  => 'root',
    mode   => '0755',
    content => '---
:backends:
  - yaml

:hierarchy:
  - "role/%{::role}"
  - "fqdn/%{::fqdn}"
  - "tier/%{::tier}"
  - common

:yaml:
  :datadir: "/etc/puppetlabs/puppet/hiera/hiera_%{::environment}"
',
    notify => Service['pe-httpd'],
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
