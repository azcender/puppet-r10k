# Installs the Docker daemon
#

class profile::docker {
  # Include base class
  include ::profile
  include ::docker

  # Docker runs in docker yaml
  $runs = hiera('profile::docker::runs')

  create_resources('::docker::run', $runs)

  # Create haproxy mappings
  create_resources('::profile::helper_docker_haproxy', $runs)
}
