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

  # Execute augesus types
  $augeas = hiera_hash(augeas, {})
  create_resources(augeas, $augeas)

  # Execute execs
  $execs = hiera_hash(execs, {})
  create_resources(exec, $execs)

  # Execute concat types
  $concats = hiera_hash(concats, {})
  create_resources(concat, $concats)

  # Execute concat fragemnts
  $concat_fragments = hiera_hash(concat_fragments, {})
  create_resources(concat::fragment, $concat_fragments)

  # Create defined host entrier
  $hosts = hiera_hash(hosts, {})
  create_resources(host, $hosts)

  # Create defined files
  $files = hiera_hash(files, {})
  create_resources(file, $files)

  # Create defined groups
  $groups = hiera_hash(groups, {})
  create_resources(group, $groups)

  # Compile defined users and create
  $users = hiera_hash(users, {})
  create_resources(user, $users)

  # Compile file lines
  $file_lines = hiera_hash(file_lines, {})
  create_resources(file_line, $file_lines)

  # Compile packages
  $packages = hiera_array('packages', [])
  package { $packages: }
}
