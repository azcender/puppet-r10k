# Lays foundation for Oracle Database
class profile::oracle_database (
) {
  include ::profile
  
  $rac_instance = hiera('profile::oracle_database::rac_instance')

  Host <<| tag == $rac_instance |>>
  # Add concat fragments
  #  ::concat::fragment { 'sudoers_oracle_tail' :
  #  target  =>'/etc/sudoers.d/oracle',
  #  content => template('profile/oracle/oracle_database_sudoers.erb'),
  #  order   => '10',
  #}
}
