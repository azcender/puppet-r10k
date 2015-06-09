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
  $image,
  $username,
  $memory_limit,
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
  $extra_parameters = undef,
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

  validate_re($image, '^[\S]*$')
  validate_re($title, '^[\S]*$')
  validate_re($memory_limit, '^[\d]*(b|k|m|g)$')

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

  # Containers cannot be run privileged
  validate_re($privileged, false, 'Containers cannot be privileged')

  # Containers must run as a user other than root
  # It is a required param so it is already included if this point is reached
  validate_re($username, '[^\s*root]', 'Users cannot run as root')

  ::docker::run { $name:
    image            => $image,
    command          => $command,
    memory_limit     => $memory_limit,
    cpuset           => $cpuset,
    ports            => $ports,
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
    extra_parameters => $extra_parameters,
    pull_on_start    => $pull_on_start,
    depends          => $depends,
    tty              => $tty,
    socket_connect   => $socket_connect,
    hostentries      => $hostentries,
    restart          => $restart,
  }
}
