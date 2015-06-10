# openstack storage

class profile::openstack_storage {
  include ::profile
  include ::openstack::role::storage
}
