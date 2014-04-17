class profiles::app_servers inherits profiles {

  # Hiera lookups
  $instances = hiera('profiles::app_servers::instances')
  $apps      = hiera('profiles::app_servers::apps')

  include ::tomcat

  create_resources('tomcat::instance', $instances)
  create_resources('wget::fetch', $apps)
}
