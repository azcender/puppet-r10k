# Sets up the base oracle build
class profile::oracle (
  $files,
  $packages,
) {
  include ::profile
  
  # Create packages needed for base Oracle build
  package { $packages: }

  # Create files needed for base Oracle build
  file { $files: }
}
