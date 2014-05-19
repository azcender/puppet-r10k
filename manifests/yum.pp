class profiles::yum inherits profiles {
  createrepo { 'yumrepo':
    repository_dir => '/var/yumrepos/yumrepo',
    repo_cache_dir => '/var/cache/yumrepos/yumrepo'
  }
}
