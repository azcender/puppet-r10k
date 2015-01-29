# Profile for standard LAMP (Linux Apache MySQL PHP) server.
class profile::lap {

   include ::profile
   include ::lap

   firewall { '100 allow http and https access':
     port   => [80, 443],
     proto  => tcp,
     action => accept,
   }

}
