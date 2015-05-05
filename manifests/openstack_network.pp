# openstack network

class profile::openstack_network {
  include ::profile
  include ::openstack::role::network
}
