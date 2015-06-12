# Installs the Docker daemon
#
# [ipaddress]
#   The ipaddress the docker host can listed to for container requests.
#   A node may have multiple networks, but docker should be limited to one.
#   for security reasons.
#
#   - String
#   - OPTIONAL
#     - default: ipaddress fact
#
# [images]
#   The images docker should pull down and cache locally.
#
#   - Hash
#   - OPTIONAL
#     - default: empty
#
# [runs]
#   The container runs docker should initiate and maintain.
#
#   - Hash
#   - OPTIONAL
#     - default: empty
class profile::docker(
  $ipaddress,
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

  # Pass in the set ip address for docker runs
  $default_params = {
    ipaddress => $ipaddress,
  }

  # Create and runs being passed in
  create_resources(::profile::docker::run, $runs, $default_params)

  # Create haproxy mappings
  create_resources(::profile::docker::haproxy, $runs, $default_params)
}
