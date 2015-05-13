# openstack controller

class profile::openstack_controller {
  include ::profile
  include ::openstack::role::controller
}
