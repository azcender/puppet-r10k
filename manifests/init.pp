# Does basic setup for all profiles
# Puppet master DOES NOT inherit from this
class profile {
  # Puppet agent dev environment
  # Default: production
  $puppet_agent_environment =
    hiera('profile::puppet_agent_environment', 'production')

  # Puppet agent polling interval
  # Default:  1800 (30 mins)
  $puppet_agent_runinterval =
    hiera('profile::puppet_agent_runinterval', '1800')

  # Initialization value for puppet development environment:
  #    production
  #    staging
  #    dev
  #    other (Often names for user id)
  ini_setting { 'set puppet development environment':
    ensure   => present,
    path     => '/etc/puppetlabs/puppet/puppet.conf',
    section  => 'agent',
    setting  => 'environment',
    value    => $puppet_agent_environment,
  }

  # Set agent polling interval
  ini_setting { 'set puppet agent polling interval':
    ensure   => present,
    path     => '/etc/puppetlabs/puppet/puppet.conf',
    section  => 'main',
    setting  => 'runinterval',
    value    => $puppet_agent_runinterval,
  }
}
