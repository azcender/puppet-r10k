# Sets up the base oracle build
class profile::oracle (
  $files,
  $groups,
  $packages,
  $users
) {
  include ::profile

  # Basic validation of params
  validate_array($packages)

  validate_hash($files)
  
  # Create packages needed for base Oracle build
  package { $packages: }

  # Create files needed for base Oracle build
  create_resources(file, $files)

  # Create users needed for base Oracle build
  create_resources(user, $users)

  # Create groups needed for base Oracle build
  create_resources(group, $groups)
}
