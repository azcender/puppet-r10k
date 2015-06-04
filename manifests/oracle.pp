# Sets up the base oracle build
class profile::oracle (
  $packages,
) {
  include ::profile
  
  # Create packages needed for base Oracle build
  package { $packages: }
}
