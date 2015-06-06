# Sets up the base oracle build
class profile::oracle (
  $augeas,
  $files,
  $groups,
  $packages,
  $users
) {
  include ::profile

  # Basic validation of params
  validate_array($packages)

  validate_hash($augeas)
  validate_hash($files)
  validate_hash($users)
  validate_hash($groups)
  
  # Create packages needed for base Oracle build
  package { $packages: }

  # Manipulate complex files using augeas
  create_resources(augeas, $augeas)

  # Create files needed for base Oracle build
  create_resources(file, $files)

  # Create users needed for base Oracle build
  create_resources(user, $users)

  # Create groups needed for base Oracle build
  create_resources(group, $groups)
}
