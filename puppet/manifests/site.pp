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

  ini_setting { 'set puppet agent environment':
    ensure   => present,
    path     => '/etc/puppetlabs/puppet/puppet.conf',
    section  => 'agent',
    setting  => 'environment',
    value    => 'dev',
  }

  ini_setting { 'set puppet agent polling interval':
    ensure   => present,
    path     => '/etc/puppetlabs/puppet/puppet.conf',
    section  => 'main',
    setting  => 'runinterval',
    value    => '60',
  }

##### mDNS - begin #####
# case $::osfamily {
#
#   'redhat': {
#     exec{'retrieve_epel_key':
#       command => "/usr/bin/wget --no-check-certificate -q https://fedoraproject.org/static/217521F6.txt -O /etc/pki/rpm-gpg/RPM-GPG-KEY-EPEL",
#       creates => "/etc/pki/rpm-gpg/RPM-GPG-KEY-EPEL",
#     }
#     file{'/etc/pki/rpm-gpg/RPM-GPG-KEY-EPEL':
#       owner   => root,
#       group   => root,
#       mode    => 0444,
#       require => Exec["retrieve_epel_key"],
#     }
#     yumrepo { "epel":
#       mirrorlist => 'http://mirrors.fedoraproject.org/mirrorlist?repo=epel-5&arch=$basearch',
#       enabled    => 1,
#       gpgcheck   => 1,
#       gpgkey     => "file:///etc/pki/rpm-gpg/RPM-GPG-KEY-EPEL",
#       require    => File["/etc/pki/rpm-gpg/RPM-GPG-KEY-EPEL"]
#     }
#     $mdns_packages = ['nss-mdns', 'avahi']
#     package { 'nss-mdns':
#       ensure  => installed,
#       require => Yumrepo[ "epel" ],
#     }
#     package { 'avahi':
#       ensure  => installed,
#       require => Package['nss-mdns'],
#     }
#     service { 'avahi-daemon':
#       ensure   => running,
#       require  => Package['nss-mdns'],
#     }
#   }
#
#   'debian': {
#     $mdns_packages = ['lib32nss-mdns', 'avahi-daemon']
#     package { $mdns_packages: ensure => installed }
#   }
#
#   default: {
#     $mdns_packages = ['nss-mdns', 'avahi']
#     package { $mdns_packages: ensure => installed }
#   }
# }
##### mDNS - end #####

}

node /^master.*$/ inherits base {
  if $::osfamily == 'redhat' {
    class { 'firewall': ensure => stopped, }
  }

  package { 'git': ensure => present, }

  file { 'r10k environments dir':
    ensure   => directory,
    path     => '/etc/puppetlabs/puppet/environments',
  }

  class { 'r10k':
    remote   => hiera('r10k_repo', 'git@bitbucket.org:prolixalias/puppet-r10k-environments.git')
  }

  exec { 'r10k deploy environment --puppetfile':
    path     => ['/bin','/sbin','/usr/bin','/usr/sbin','/opt/puppet/bin'],
    require  => [Package['git'],File['r10k environments dir'],Class['r10k::install']],
  }

# include r10k::prerun_command
  include r10k::mcollective

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
#    setting => 'heira_config',
#    value   => '/etc/puppetlabs/puppet/environments/$environment/hiera.yaml',
#  }

  file { '/etc/puppetlabs/puppet/hiera.yaml':
    ensure   => file, mode => '0755', owner => 'root', group => 'root',
    source   => 'file:///vagrant/puppet/files/hiera.yaml',
    notify   => Service['pe-httpd'],
  }

  service { 'pe-httpd': ensure => running, }

  Ini_setting['set puppet agent environment'] {
    value    => 'production',
  }
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
