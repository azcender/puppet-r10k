# foundation for Oracle Database

class profile::oracle_database (
  $nic_priv = undef,
  $nic_iscsi = undef,
  $rac_instance = undef
) {
  $regex_ip_address = '^(?:[0-9]{1,3}\.){3}[0-9]{1,3}$'  #  regex to ensure value is an IP address
  validate_re($nic_prod, $regex_ip_address, "Required production NIC (prod) seems to have an invalid value of: '${nic_prod}'")
  validate_re($nic_priv, $regex_ip_address, "Required interconnect (priv) NIC seems to have an invalid value of: '${nic_priv}'")
  validate_re($nic_iscsi, $regex_ip_address, "Required iSCSI (iscsi) NIC seems to have an invalid value of: '${nic_iscsi}'")

  include ::profile

  $rac_instance = hiera('profile::oracle_database::rac_instance')
  Host <<| tag == "${rac_instance}" |>>

  # each NIC on each RAC node needs to have self/peer lines in /etc/hosts
  # FQDN per prerequisites doc

  # production interface per prerequisites doc
  @@host { "${::fqdn}":
    ensure       => present,
    host_aliases => ["${::hostname}"],
    ip           => "${nic_prod}",
    tag          => "${rac_instance}",
  }

  ### if you're getting a "Parameter ip failed on Host: Invalid IP address" error on agent run, one of
  ### the interfaces below is most likely misconfigured on the node. Validate interfaces and addresses

  # private VLAN interface per prerequisites doc
  @@host { "${::hostname}-priv":
    ensure => present,
    ip     => "${nic_priv}",
    tag    => "${rac_instance}",
  }

  # iSCSI interface per prerequisites doc
  @@host { "${::hostname}-iscsi":
    ensure => present,
    ip     => "${nic_iscsi}",
    tag    => "${rac_instance}",
  }

  # Add concat fragments
  #  ::concat::fragment { 'sudoers_oracle_tail' :
  #  target  =>'/etc/sudoers.d/oracle',
  #  content => template('profile/oracle/oracle_database_sudoers.erb'),
  #  order   => '10',
  #}
  }
