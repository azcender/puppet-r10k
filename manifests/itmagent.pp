# Profile for IBM Tivoli Monitoring (ITM) Agent
class profile::itmagent {
   include ::profile
   class { '::itmagent':
     itm_server     => hiera('profile::itmagent::itm_server'),
     src_dir        => hiera('profile::itmagent::src_dir'),
     dir_tmp        => hiera('profile::itmagent::dir_tmp'),
   }
}
