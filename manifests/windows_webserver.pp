# Setup IIS to host site(s)
class profile::windows_webserver inherits profile {
  iis::manage_app_pool {'MyAppPool':
    enable_32_bit           => true,
    managed_runtime_version => 'v4.0',
  } ->

  iis::manage_site {'DemoSite':
    site_path   => 'C:\inetpub\wwwroot',
    port        => '80',
    ip_address  => '*',
    app_pool    => 'MyAppPool'
  } ->

  iis::manage_virtual_application {'VirtualApp':
    site_name  => 'DemoSite',
    site_path  => 'C:\inetpub\wwwroot\MyVirtualApp',
    app_pool   => 'MyAppPool'
  } -> 

  iis::manage_binding {'DemoSite-8080':
    site_name  => 'DemoSite',
    protocol   => 'http',
    port       => '8080',
    ip_address => '*'
  }
}
