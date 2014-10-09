# Does basic setup for all profiles
# Puppet master DOES NOT inherit from this
class profile {
  $run_path   = "set /files/etc/puppetlabs/puppet/auth.conf/path[. = '/run'] /run"
  $run_auth   = "set /files/etc/puppetlabs/puppet/auth.conf/path[. = '/run']/auth any"
  $run_method = "set /files/etc/puppetlabs/puppet/auth.conf/path[. = '/run']/method/1 save"
  $run_allow  = "set /files/etc/puppetlabs/puppet/auth.conf/path[. = '/run']/allow/1 *"

  $remove_root = "rm /files/etc/puppetlabs/puppet/auth.conf/path[. = '/']"

  # Add puppet auth entry for run
  augeas { "auth.conf":
    changes => [$run_path, $run_auth, $run_method, $run_allow, $remove_root],
  }

  # Puppet agent dev environment
  # Default: production
  $puppet_agent_environment =
    hiera('profile::puppet_agent_environment')

  # Puppet agent environment should default to production
  $agent_environment = $puppet_agent_environment? {
    ''      => 'production',
    default => $puppet_agent_environment
  }

  # Puppet intended agent polling interval
  # Default:  1800 (30 mins)
  $puppet_agent_runinterval =
    hiera('profile::puppet_agent_runinterval')

  # Empty runintervals are not allowed
  $runinterval = $puppet_agent_runinterval? {
    ''      => '1800',
    default => $puppet_agent_runinterval
  }

  # Initialization value for puppet environment:
  #    production
  #    staging
  #    dev
  #    other (Often names for user id)
  case $::operatingsystem {
    windows: {
      $puppet_conf_path = 'C:/ProgramData/PuppetLabs/puppet/etc/puppet.conf'
    }
    Ubuntu, RedHat, CentOS: {
      # Set "environment"
      $puppet_conf_path = '/etc/puppetlabs/puppet/puppet.conf'
    }
    default: {
      fail("Unsupported operating system detected: ${::operatingsystem}")
    }
  }

  ini_setting { 'remove bogus production env from main section if present':
    ensure   => absent,
    path     => $puppet_conf_path,
    section  => 'main',
    setting  => 'environment',
    value    => 'production',
  }

  ini_setting { 'set puppet development environment':
    ensure   => present,
    path     => $puppet_conf_path,
    section  => 'agent',
    setting  => 'environment',
    value    => $agent_environment,
  }

  # Set agent polling interval
  ini_setting { 'set puppet agent polling interval':
    ensure   => present,
    path     => $puppet_conf_path,
    section  => 'main',
    setting  => 'runinterval',
    value    => $runinterval,
  }

  # Set HTTP listener on
  ini_setting { 'set http api listener on':
    ensure   => present,
    path     => $puppet_conf_path,
    section  => 'agent',
    setting  => 'listen',
    value    => true,
  }

  # Enable pluginsync
  ini_setting { 'enable pluginsync':
    ensure   => present,
    path     => $puppet_conf_path,
    section  => 'main',
    setting  => 'pluginsync',
    value    => true,
  }

  # causing all kinds of trouble in work area
  #host { 'localhost':
  #  ip => '127.0.0.1',
  #  #host_aliases => [ "${hostname}", "${fqdn}" ],
  #  host_aliases => [ "${hostname}" ],
  #}

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
