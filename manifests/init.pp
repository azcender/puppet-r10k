#
# Does basic setup for all profiles
# Puppet master DOES NOT inherit from this
#

class profile {
  # Puppet agent dev environment
  # Default: production
  $agent_environment = hiera('profile::puppet_agent_environment', 'production')

  # Puppet intended agent polling interval
  # Default:  1800 (30 mins)
  $runinterval = hiera('profile::puppet_agent_runinterval', '1800')

  # Create defined files
  $files = hiera_hash('files', {})

  create_resources(file, $files)

  # Create defined groups
  $groups = hiera_hash('groups', {})

  create_resources(group, $groups)

  # Compile defined users and create
  $users = hiera_hash('users', {})

  create_resources(user, $users)

  # Compile packages
  $packages = hiera_hash('packages', {})

  package { $packages: }
}
