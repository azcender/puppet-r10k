class profiles::yum inherits profiles {
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
}
