# == Define: docker:run
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
define profile::helper_docker_haproxy(
  $image,
  $command = undef,
  $memory_limit = '0b',
  $cpuset = [],
  $ports = [],
  $expose = [],
  $volumes = [],
  $links = [],
  $use_name = false,
  $running = true,
  $volumes_from = [],
  $net = 'bridge',
  $username = false,
  $hostname = false,
  $env = [],
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
  # Only really worried about ports
  validate_array($ports)

  ::profile::helper_docker_haproxy_port { $ports:
    ports   => $ports,
    running => $running,
  }
}
