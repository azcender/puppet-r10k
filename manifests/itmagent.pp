# Profile for IBM Tivoli Monitoring (ITM) Agent
class profile::itmagent {

   include ::profile
   include ::itmagent
   class { '::itmagent':
     itm_server => 'temsy.blacklab.lan',
     nfs_host   => '10.20.1.8',
     mnt_dir    => '/mnt/centos70s0',
   }

}
