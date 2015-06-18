#
# == Define: profile:docker:run
#
# A define which manages a running docker container.
#
# == Parameters
#
# [*restart*]
# Sets a restart policy on the docker run.
# Note: If set, puppet will NOT setup an init script to manage, instead
# it will do a raw docker run command using a CID file to track the container 
# ID.
#
# If you want a normal named container with an init script and a restart policy
# you must use the extra_parameters feature and pass it in like this:
#
#    extra_parameters => ['--restart=always']
#
# This will allow the docker container to be restarted if it dies, without
# puppet help.
#
# [*extra_parameters*]
# An array of additional command line arguments to pass to the `docker run`
# command. Useful for adding additional new or experimental options that the
# module does not yet support.
#
# This is a subprofile of the standard docker run. This contains hardening
# data checks.
define profile::docker::run(
  $ipaddress,
  $image,
  $username,
  $memory_limit = undef,
  $command = undef,
  $cpuset = [],
  $ports = [],
  $expose = [],
  $volumes = [],
  $links = [],
  $use_name = false,
  $running = true,
  $volumes_from = [],
  $net = 'bridge',
  $hostname = false,
  $env = [],
  $env_file = [],
  $dns = [],
  $dns_search = [],
  $lxc_conf = [],
  $restart_service = true,
  $disable_network = false,
  $privileged = false,
  $detach = undef,
  $extra_parameters = [],
  $pull_on_start = false,
  $depends = [],
  $tty = false,
  $socket_connect = [],
  $hostentries = [],
  $restart = undef,
) {
  include ::docker::params

  $docker_command = $docker::params::docker_command
  $service_name = $docker::params::service_name

  validate_array($extra_parameters)

  validate_re($image, '^[\S]*$')
  validate_re($title, '^[\S]*$')

  if $restart {
    validate_re($restart, '^(no|always)|^on-failure:[\d]+$')
  }

  validate_string($docker_command)
  validate_string($service_name)

  if $command {
    validate_string($command)
  }

  if $username {
    validate_string($username)
  }

  if $hostname {
    validate_string($hostname)
  }

  validate_bool($running)
  validate_bool($disable_network)
  validate_bool($restart_service)
  validate_bool($tty)
  validate_bool($privileged)

  # 4.1 Create a user for the container
  # Containers must run as a user other than root
  # It is a required param so it is already included if this point is reached
  #  case strip($username) {
  #  'root':  {
  #    fail('Security concern -- A non root must be specified for a run.')
  #  }
  #
  #  undef:   {
  #    fail('Security concern -- A non root must be specified for a run.')
  #  }
  #
  #  default: {}
  #}

  # 5.5 Do not use privileged containers
  # Containers cannot be run privileged
  if $privileged {
    fail('Security concern -- Containers cannot be privileged')
  }

  $_check_privilege_extra_params = grep($extra_parameters, '--privileged')

  case size($_check_privilege_extra_params) {
    0:       {}
    default: { fail('Security concern -- Containers cannot be privileged') }
  }

  # 5.6 Do not mount sensitive host system directories on containers
  $check_sensitive_mounts =
    grep($volumes, '^\s*\/:|\/boot:|\/dev:|\/etc:|\/lib:|\/proc:|\/sys:|\/usr:')

  if size($check_sensitive_mounts) != 0 {
    fail("Security concern -- /, /boot, /dev, /etc, /lib, /proc, /sys, and /usr host directories cannot be mounted. ${check_sensitive_mounts}")
  }

  # 5.9 Open only needed ports on container
  $check_cap_p_option = grep($extra_parameters, '-P')

  if size($check_cap_p_option) != 0 {
    fail('Security concern -- Containers runs cannot use "-P" option. orts must be explicitly mapped.')
  }

  # 5.10 Do not use host network mode on container
  if 'host' == strip($net) {
    fail('Security concern -- Containers cannot network directly to host')
  }

  # 5.11 Limit memory usage for container
  validate_re($memory_limit,
    '^[\d]+(b|k|m|g)$', 'Security concern -- Memory limit must be set.')

  # 5.13 Mount container's root filesystem as read only
  $_extra_parameters = union($extra_parameters, ['--read-only'])

  # 5.14 Bind incoming container traffic to a specific host interface
  $_check_port_mappings =
    grep($ports, '^\d+:\d+$')

  if size($_check_port_mappings) != size($ports) {
    $port_differences = difference($ports, $_check_port_mappings)
    fail("Security concern -- Ports must be in the form of <host port>>:<<container port>>. IP binding is enforced through the profile ipaddress.  ${port_differences}")
  }

  # Prepend ip address to port mappings
  $_ports = prefix($ports, "${ipaddress}:")

  # 5.16 Do not share the host's process namespace
  $_check_pid_is_host = grep($extra_parameters, '--pid=host')

  if size($_check_pid_is_host) != 0 {
    fail('Security concern -- Containers cannot run pid=host')
  }

  # 5.17 Do not share the host's IPC namespace
  $_check_ipc_is_host = grep($extra_parameters, '--ipc=host')

  if size($_check_ipc_is_host) != 0 {
    fail('Security concern -- Containers cannot run ipc=host')
  }

  # 5.18 Do not directly expose host devices to containers
  $_check_device_mapping = grep($extra_parameters, '--device')

  if size($_check_device_mapping) != 0 {
    fail("Security concern -- Containers cannot map devices. ${_check_device_mapping}")
  }

  ::docker::run { $name:
    image            => $image,
    command          => $command,
    memory_limit     => $memory_limit,
    cpuset           => $cpuset,
    ports            => $_ports,
    expose           => $expose,
    volumes          => $volumes,
    links            => $links,
    use_name         => $use_name,
    running          => $running,
    volumes_from     => $volumes_from,
    net              => $net,
    username         => $username,
    hostname         => $hostname,
    env              => $env,
    env_file         => $env_file,
    dns              => $dns,
    dns_search       => $dns_search,
    lxc_conf         => $lxc_conf,
    restart_service  => $restart_service,
    disable_network  => $disable_network,
    privileged       => $privileged,
    detach           => $detach,
    extra_parameters => $_extra_parameters,
    pull_on_start    => $pull_on_start,
    depends          => $depends,
    tty              => $tty,
    socket_connect   => $socket_connect,
    hostentries      => $hostentries,
    restart          => $restart,
  }
}
