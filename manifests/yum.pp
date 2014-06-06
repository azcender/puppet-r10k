# Constructs a yum profile along with a web server
class profile::yum inherits profile {
  # Create parent directory for repo
  file { '/var':
    ensure => 'directory'
  } ->

  file { '/var/yumrepos':
    ensure => 'directory'
  } ->

  file { '/var/cache':
    ensure => 'directory'
  } ->

  file { '/var/cache/yumrepos':
    ensure => 'directory'
  } ->

  createrepo { 'yumrepo':
    repository_dir => '/var/yumrepos/yumrepo',
    repo_cache_dir => '/var/cache/yumrepos/yumrepo'
  }

  class { 'apache': }

  apache::vhost { 'yum.azcender.com':
    port        => '80',
    docroot     => '/var/yumrepos/yumrepo',
    directories => [
      { path    => '/var/yumrepos/yumrepo',
        options => ['Indexes'], }
    ],
  }
}
