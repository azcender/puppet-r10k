# Lays foundation for Oracle Database
class profile::oracle_database (
) {
  include ::profile
  # Add concat fragments
  #  ::concat::fragment { 'sudoers_oracle_tail' :
  #  target  =>'/etc/sudoers.d/oracle',
  #  content => template('profile/oracle/oracle_database_sudoers.erb'),
  #  order   => '10',
  #}
}
