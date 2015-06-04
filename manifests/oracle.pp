# Sets up the base oracle build
class profile::oracle (
  $packages,
) {
  include ::profile
  
  # Create packages needed for base Oracle build
  create_resources(package, $packages)
}
