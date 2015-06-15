# test
#
# one machine setup with weblogic 10.3.6 with BSU
# needs jdk7, orawls, orautils, fiddyspence-sysctl, erwbgy-limits puppet modules
#

class profile::weblogic::nodemanager {
  $default_params_nodemanager = { }

  $nodemanager_instances = hiera('nodemanager_instances', {})
  create_resources(::orawls::nodemanager, $nodemanager_instances,
  $default_params_nodemanager)

  $version = hiera('wls_version')

  orautils::nodemanagerautostart{'autostart weblogic 11g':
    version                 => $version,
    wlHome                  => hiera('wls_weblogic_home_dir'),
    user                    => hiera('wls_os_user'),
    jsseEnabled             => hiera('wls_jsse_enabled'             ,false),
    customTrust             => hiera('wls_custom_trust'             ,false),
    trustKeystoreFile       => hiera('wls_trust_keystore_file'      ,undef),
    trustKeystorePassphrase => hiera('wls_trust_keystore_passphrase',undef),
  }
}
