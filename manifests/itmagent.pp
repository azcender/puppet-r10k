# Profile for IBM Tivoli Monitoring (ITM) Agent
class profile::itmagent {
   include ::profile
   class { '::itmagent':
     itm_server     => 'temsy.blacklab.lan',
     nfs_host       => '10.20.1.8',
     mnt_dir        => '/mnt/centos70s0',
     src_dir        => 'itm630agent_inst'
     nfs_dir        => '/var/centos70s0'
     dir_tmp        => '/tmp'
     nfs_options    => '-t nfs'
   }
}
