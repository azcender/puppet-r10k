# test
#
# one machine setup with weblogic 10.3.6 with BSU
# needs jdk7, orawls, orautils, fiddyspence-sysctl, erwbgy-limits puppet modules
#

class profile::weblogic::control {
  include ::profile::weblogic::nodemanager

  $default_startwls_params = {
    tag => 'wls_control',
  }

  $control_instances = hiera('control_instances', {})
  create_resources('orawls::control', $control_instances,
  $default_startwls_params)
}
