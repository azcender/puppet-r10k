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

  file { 'r10k environments dir':
    ensure   => directory,
    path     => '/etc/puppetlabs/puppet/environments',
  } ->

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

  exec { 'r10k deploy environment --puppetfile':
    path     => ['/bin','/sbin','/usr/bin','/usr/sbin','/opt/puppet/bin'],
    require  => [Package['git'],File['r10k environments dir'],Class['r10k::install']],
    timeout  => 0,
  } ->

  # Make sure the modules are readable (Only prod initially)
  file {'/etc/puppetlabs/puppet/environments/production':
    mode    => 'a+r',
    recurse => 'true'
  } ->

  # Make sure hire directory is readable too
  file {"${::settings::confdir}/hiera" :
    mode    => 'a+r',
    recurse => 'true'
  } ->

  ini_setting { 'master manifest path':
    ensure   => present,
    path     => '/etc/puppetlabs/puppet/puppet.conf',
    section  => 'main',
    setting  => 'manifest',
    value    => '/etc/puppetlabs/puppet/environments/$environment/manifests/site.pp',
  }

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
