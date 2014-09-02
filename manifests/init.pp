# Does basic setup for all profiles
# Puppet master DOES NOT inherit from this
class profile {
  # Puppet agent dev environment
  # Default: production
  $puppet_agent_environment =
    hiera('profile::puppet_agent_environment')

  # Puppet agent environment should default to production
  $agent_environment = $puppet_agent_environment? {
    ''      => 'production',
    default => $puppet_agent_environment
  }

  # Puppet agent polling interval
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
      # Set "environment"
      ini_setting { 'set puppet environment':
        ensure   => present,
        path     => 'C:\Program Files (x86)\Puppet Labs\Puppet Enterprise\puppet\ext\puppet.conf',
        section  => 'agent',
        setting  => 'environment',
        value    => $agent_environment,
      }

      # Set agent polling interval
      ini_setting { 'set puppet agent polling interval':
        ensure   => present,
        path     => 'C:\Program Files (x86)\Puppet Labs\Puppet Enterprise\puppet\ext\puppet.conf',
        section  => 'main',
        setting  => 'runinterval',
        value    => $runinterval,
      }

      # Set http listener on
      ini_setting { 'set http api listener on':
        ensure   => present,
        path     => 'C:\Program Files (x86)\Puppet Labs\Puppet Enterprise\puppet\ext\puppet.conf',
        section  => 'agent',
        setting  => 'listen',
        value    => true,
      }
    }
    Ubuntu, RedHat, CentOS: {
      # Set "environment"
      ini_setting { 'set puppet development environment':
        ensure   => present,
        path     => '/etc/puppetlabs/puppet/puppet.conf',
        section  => 'agent',
        setting  => 'environment',
        value    => $agent_environment,
      }

      # Set agent polling interval
      ini_setting { 'set puppet agent polling interval':
        ensure   => present,
        path     => '/etc/puppetlabs/puppet/puppet.conf',
        section  => 'main',
        setting  => 'runinterval',
        value    => $runinterval,
      }

      # Set http listener on
      ini_setting { 'set http api listener on':
        ensure   => present,
        path     => '/etc/puppetlabs/puppet/puppet.conf',
        section  => 'agent',
        setting  => 'listen',
        value    => true,
      }
    }
    default: {
      fail("Unsupported operating system detected: ${::operatingsystem}")
    }
  }
}
