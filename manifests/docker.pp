# Installs the Docker daemon
class profile::docker {
  # Include base class
  include ::profile

  include ::docker

  # Pull images
  $images = hiera('profile::docker::images')

  create_resources('::docker::image', $images)
}
