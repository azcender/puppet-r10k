# openstack compute

class profile::openstack_compute {
  include ::profile
  include ::openstack::role::compute
}
