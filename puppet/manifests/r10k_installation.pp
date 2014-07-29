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
