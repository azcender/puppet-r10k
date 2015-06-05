# Sets up the base oracle build
class profile::oracle (
  $files,
  $packages,
) {
  include ::profile

  # Basic validation of params
  validate_array($packages)

  validate_hash($files)
  
  # Create packages needed for base Oracle build
  package { $packages: }

  # Create files needed for base Oracle build
  create_resources(file, $files)
}
