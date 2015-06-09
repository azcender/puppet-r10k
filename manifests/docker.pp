# Installs the Docker daemon
#

class profile::docker(
  $images = {},
  $runs = {},
) {
  # Basic validations
  validate_hash($images)
  validate_hash($runs)

  # Include base class
  include ::profile
  include ::docker

  service { 'auditd':
    ensure  => running,
    restart => '/sbin/service auditd restart',
  }

  # Create and runs being passed in
  create_resources(::profile::docker::run, $runs)

  # Create haproxy mappings
  create_resources(::profile::helper_docker_haproxy, $runs)
}
