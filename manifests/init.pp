# Does basic setup for all profiles
# Puppet master DOES NOT inherit from this
class profile {

  include ::sanity

  $run_path   = "set /files${::confdir}/auth.conf/path[. = '/run'] /run"
  $run_auth   = "set /files${::confdir}/auth.conf/path[. = '/run']/auth any"
  $run_method =
    "set /files${::confdir}/auth.conf/path[. = '/run']/method/1 save"
  $run_allow  = "set /files${::confdir}/auth.conf/path[. = '/run']/allow/1 *"

  $remove_root = "rm ${::confdir}/auth.conf/path[. = '/']"

  # Add puppet auth entry for run
  augeas { 'auth.conf':
    changes => [$run_path, $run_auth, $run_method, $run_allow, $remove_root],
  }

  # Puppet agent dev environment
  # Default: production
  $agent_environment =
    hiera('profile::puppet_agent_environment', 'production')

  # Puppet intended agent polling interval
  # Default:  1800 (30 mins)
  $runinterval = hiera('profile::puppet_agent_runinterval', '1800')

  ini_setting { 'remove bogus production env from main section if present':
    ensure  => absent,
    path    => "${::confdir}/puppet.conf",
    section => 'main',
    setting => 'environment',
    value   => 'production',
  }

  ini_setting { 'set puppet development environment':
    ensure  => present,
    path    => "${::confdir}/puppet.conf",
    section => 'agent',
    setting => 'environment',
    value   => $agent_environment,
  }

  # Set agent polling interval
  ini_setting { 'set puppet agent polling interval':
    ensure  => present,
    path    => "${::confdir}/puppet.conf",
    section => 'main',
    setting => 'runinterval',
    value   => $runinterval,
  }

  # Set HTTP listener on
  ini_setting { 'set http api listener on':
    ensure  => present,
    path    => "${::confdir}/puppet.conf",
    section => 'agent',
    setting => 'listen',
    value   => true,
  }

  # Enable pluginsync
  ini_setting { 'enable pluginsync':
    ensure  => present,
    path    => "${::confdir}/puppet.conf",
    section => 'main',
    setting => 'pluginsync',
    value   => true,
  }

  # Create defined files
  $files = hiera_hash('files', {})

  create_resources(file, $files)

  # Create defined groups
  $groups = hiera_hash('groups', {})

  create_resources(group, $groups)

  # Compile defined users and create
  $users = hiera_hash('users', {})

  create_resources(user, $users)

}
