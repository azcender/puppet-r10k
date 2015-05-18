# Set up a haproxy proxy
#

class profile::haproxy {
  # Include base class
  include ::profile
  include ::haproxy

  ::Docker::Run <<||>> ->
    ::Haproxy::Balancermember <<| listening_service == 'docker' |>>

}
