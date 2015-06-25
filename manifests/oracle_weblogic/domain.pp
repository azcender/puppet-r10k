# test
#
# one machine setup with weblogic 10.3.6 with BSU
# needs jdk7, orawls, orautils, fiddyspence-sysctl, erwbgy-limits puppet modules
#

class profile::weblogic::domain {
  # Placeholder for defaults
  $default_params = {}

  $domain_instances = hiera('domain_instances', {})
  create_resources(::orawls::domain, $domain_instances, $default_params)

  $file_domain_libs = hiera('file_domain_libs', {})
  create_resources(file, $file_domain_libs, $default_params)

  $wls_setting_instances = hiera('wls_setting_instances', {})
  create_resources(wls_setting, $wls_setting_instances, $default_params)

}
