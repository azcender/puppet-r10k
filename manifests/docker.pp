# Installs the Docker daemon
#

class profile::docker(
  $file_lines,
) {
  # Include base class
  include ::profile
  include ::docker

  # File lines to build
  create_resources(files_line, $file_lines)
  
  # Docker runs in docker yaml
  $runs = hiera('profile::docker::runs')

  create_resources(::docker::run, $runs)

  # Create haproxy mappings
  create_resources(::profile::helper_docker_haproxy, $runs)
}
