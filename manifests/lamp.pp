# A wrapper that contains all thr functionality needed for a standard LAMP 
# server (Linux Apache MySQL PHP).

class profile::lamp inherits profile {

   include ::apache
   include ::apache::mod::php
   include ::mysql::server
   include ::mysql::bindings::php

   file { "/var/www/html/index.php":
      owner => "root",
      group => "root",
      mode  => 0644,
      replace => "false",
      source => "puppet:///files/lamp_html/index.php"
   }

   file { "/var/www/html/lamp.php":
      owner => "root",
      group => "root",
      mode  => 0644,
      replace => "false",
      source => "puppet:///files/lamp_html/lamp.php"
   }

}
