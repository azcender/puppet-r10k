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
) {
  # Basic validations
  validate_hash($images)

  # Call runs across hiera
  $runs = hiera_hash(profile::docker::runs, {})

  # Include base class
  include ::profile
  include ::docker

  service { 'auditd':
    ensure  => running,
    restart => '/sbin/service auditd restart',
  }

  # Start the cadvisor container with root
  # Runs as root user
  ::docker::run { 'cadvisor':
    image        => 'google/cadvisor:latest',
    ports        => [ "${ipaddress}:9000:8080" ],
    volumes      =>
    ['/:/rootfs:ro', '/var/run:/var/run:rw', '/sys:/sys:ro',
    '/var/lib/docker/:/var/lib/docker:ro ', '/cgroup:/cgroup:ro'],
    memory_limit => '512m',
    username     => 'root',
    links        => [ 'influxsrv:influxsrv' ],
  }

  ::docker::run { 'influxsrv':
    image  => 'tutum/influxdb',
    ports  => [ "${ipaddress}:8083:8083", "${ipaddress}:8086:8086" ],
    env    => [ 'PRE_CREATE_DB=cadvisor' ],
    expose => [ '8090', '8099' ],
  }

  ::docker::run { 'grafana':
    image => 'grafana/grafana',
    ports => [ "${ipaddress}:3000:3000" ],
    links => [ 'influxsrv:influxsrv' ],
    env   =>
    [ 'INFLUXDB_HOST=localhost', 'INFLUXDB_PORT=8086', 'INFLUXDB_NAME=cadvisor',
    'INFLUXDB_USER=root', 'INFLUXDB_PASS=root' ],
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
