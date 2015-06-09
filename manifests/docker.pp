# Installs the Docker daemon
#

class profile::docker(
  $files,
  $file_lines,
) {
  # Include base class
  include ::profile
  include ::docker

  service { 'auditd':
    ensure  => running,
    restart => '/sbin/service auditd restart',
  }

  # File lines to build
  create_resources(file_line, $file_lines)
  
  # Create docker files
  create_resources(file, $files)

  # Docker runs in docker yaml
  $runs = hiera('profile::docker::runs')

  create_resources(::docker::run, $runs)

  # Create haproxy mappings
  create_resources(::profile::helper_docker_haproxy, $runs)
}
