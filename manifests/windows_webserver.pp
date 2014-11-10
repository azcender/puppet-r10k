# Setup IIS to host site(s)
class profile::windows_webserver {
  include ::profile

  Dism { ensure => present, }
  dism { 'IIS-WebServerRole': } ->
  dism { 'IIS-WebServer': }

  $pools = hiera('profile::windows_webserver::pools')
  create_resources('::windows_webserver::pool', $pools)
}
