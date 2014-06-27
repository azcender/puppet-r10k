# Does basic setup for all profiles
# Puppet master DOES NOT inherit from this
class profile {
  $puppet_agent_environment = hiera('profile::puppet_agent_environment')

  # Create file resources
  create_resources(ini_setting, $puppet_agent_environment)
}
