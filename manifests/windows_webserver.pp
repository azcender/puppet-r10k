# Setup IIS to host site(s)
class profile::windows_webserver inherits profile {
  Dism { ensure => present, }
  dism { 'IIS-WebServerRole': } ->
  dism { 'IIS-WebServer': }

  iis::manage_app_pool {'my_application_pool':
    enable_32_bit           => true,
    managed_runtime_version => 'v4.0',
  } ->

  iis::manage_site {'www.mysite.com':
    site_path     => 'C:\inetpub\wwwroot\mysite',
    port          => '80',
    ip_address    => '*',
    host_header   => 'www.mysite.com',
    app_pool      => 'my_application_pool'
  } ->

  iis::manage_virtual_application {'application1':
    site_name     => 'www.mysite.com',
    site_path     => 'C:\inetpub\wwwroot\application1',
    app_pool      => 'my_application_pool'
  } -> 

  iis::manage_virtual_application {'application2':
    site_name     => 'www.mysite.com',
    site_path     => 'C:\inetpub\wwwroot\application2',
    app_pool      => 'my_application_pool'
  }
}
