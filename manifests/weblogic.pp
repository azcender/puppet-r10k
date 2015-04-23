# test
#
# one machine setup with weblogic 10.3.6 with BSU
# needs jdk7, orawls, orautils, fiddyspence-sysctl, erwbgy-limits puppet modules
#

class profile::weblogic {
  # operating settings for Middleware

  $default_params = {}
  $host_instances = hiera('hosts', {})
  create_resources('host',$host_instances, $default_params)

  group { 'dba' :
    ensure => present,
  }

  # http://raftaman.net/?p=1311 for generating password
  # password = oracle
  user { 'wls' :
    ensure     => present,
    groups     => 'dba',
    shell      => '/bin/bash',
    password   => '$1$DSJ51vh6$4XzzwyIOk6Bi/54kglGk3.',
    home       => '/home/wls',
    comment    => 'wls user created by Puppet',
    managehome => true,
    require    => Group['dba'],
  }

  $install = [ 'binutils.x86_64','unzip.x86_64']


  package { $install:
    ensure  => present,
  }

  class { 'limits':
    config    => {
      '*'   => {
        'nofile' => {
          soft => '2048',
          hard => '8192',
        },
      },

      'wls' => {
        'nofile'  => {
          soft => '65536',
          hard => '65536',
        },
        'nproc'   => {
          soft => '2048',
          hard => '16384',
        },
        'memlock' => {
          soft => '1048576',
          hard => '1048576',
        },
        'stack'   => {
          soft => '10240',
        },
      },
    },

    use_hiera => false,
  }

  sysctl { 'kernel.msgmnb':
    ensure    => 'present',
    permanent => 'yes',
    value     => '65536',
  }

  sysctl { 'kernel.msgmax':
    ensure    => 'present',
    permanent => 'yes',
    value     => '65536',
  }

  sysctl { 'kernel.shmmax':
    ensure    => 'present',
    permanent => 'yes',
    value     => '2588483584',
  }

  sysctl { 'kernel.shmall':
    ensure    => 'present',
    permanent => 'yes',
    value     => '2097152',
  }

  sysctl { 'fs.file-max':
    ensure    => 'present',
    permanent => 'yes',
    value     => '6815744',
  }

  sysctl { 'net.ipv4.tcp_keepalive_time':
    ensure    => 'present',
    permanent => 'yes',
    value     => '1800',
  }

  sysctl { 'net.ipv4.tcp_keepalive_intvl':
    ensure    => 'present',
    permanent => 'yes',
    value     => '30',
  }

  sysctl { 'net.ipv4.tcp_keepalive_probes':
    ensure    => 'present',
    permanent => 'yes',
    value     => '5',
  }

  sysctl { 'net.ipv4.tcp_fin_timeout':
    ensure    => 'present',
    permanent => 'yes',
    value     => '30',
  }

  sysctl { 'kernel.shmmni':
    ensure    => 'present',
    permanent => 'yes',
    value     => '4096',
  }

  sysctl { 'fs.aio-max-nr':
    ensure    => 'present',
    permanent => 'yes',
    value     => '1048576',
  }

  sysctl { 'kernel.sem':
    ensure    => 'present',
    permanent => 'yes',
    value     => '250 32000 100 128',
  }

  sysctl { 'net.ipv4.ip_local_port_range':
    ensure    => 'present',
    permanent => 'yes',
    value     => '9000 65500',
  }

  sysctl { 'net.core.rmem_default':
    ensure    => 'present',
    permanent => 'yes',
    value     => '262144',
  }

  sysctl { 'net.core.rmem_max':
    ensure    => 'present',
    permanent => 'yes',
    value     => '4194304',
  }

  sysctl { 'net.core.wmem_default':
    ensure    => 'present',
    permanent => 'yes',
    value     => '262144',
  }

  sysctl { 'net.core.wmem_max':
    ensure    => present,
    permanent => 'yes',
    value     => '1048576',
  }

  file { '/home/wls/.ssh/':
    ensure => directory,
    owner  => 'wls',
    group  => 'dba',
    mode   => '0700',
    alias  => 'wls-ssh-dir',
  }

  file { '/home/wls/.ssh/id_rsa.pub':
    ensure  => present,
    owner   => 'wls',
    group   => 'dba',
    mode    => '0644',
    source  => '/vagrant/ssh/id_rsa.pub',
    require => File['wls-ssh-dir'],
  }

  file { '/home/wls/.ssh/id_rsa':
    ensure  => present,
    owner   => 'wls',
    group   => 'dba',
    mode    => '0600',
    source  => '/vagrant/ssh/id_rsa',
    require => File['wls-ssh-dir'],
  }

  file { '/home/wls/.ssh/authorized_keys':
    ensure  => present,
    owner   => 'wls',
    group   => 'dba',
    mode    => '0644',
    source  => '/vagrant/ssh/id_rsa.pub',
    require => File['wls-ssh-dir'],
  }

  file { '/software':
    ensure => directory,
  }

  wget::fetch { 'UnlimitedJCEPolicyJDK7':
    source      => 'http://artifactory.azcender.com/artifactory/application-deploys/com/oracle/UnlimitedJCEPolicyJDK7/7.0.0/UnlimitedJCEPolicyJDK7-7.0.0.zip',
    destination => '/software/UnlimitedJCEPolicyJDK7.zip',
    require     => File['/software'],
  }

  wget::fetch { 'JDK7':
    source      => 'http://artifactory.azcender.com/artifactory/application-deploys/com/oracle/jdk/7u55/jdk-7u55-linux-x64.tar.gz',
    destination => '/software/jdk-7u55-linux-x64.tar.gz',
    require     => File['/software'],
  }

  wget::fetch { 'wls1036_generic.jar':
    source      => 'http://artifactory.azcender.com/artifactory/ext-release-local/com/oracle/wls1036_generic/10.3.6/wls1036_generic-10.3.6.jar',
    destination => '/software/wls1036_generic.jar',
    require     => File['/software'],
  }


  $remove = [ 'java-1.7.0-openjdk.x86_64', 'java-1.6.0-openjdk.x86_64' ]

  package { $remove:
    ensure  => absent,
  }

  jdk7::install7{ 'jdk1.7.0_55':
    version                   => '7u55' ,
    fullVersion               => 'jdk1.7.0_55',
    alternativesPriority      => 18000,
    x64                       => true,
    downloadDir               => '/var/tmp/install',
    urandomJavaFix            => true,
    rsakeySizeFix             => true,
    cryptographyExtensionFile => 'UnlimitedJCEPolicyJDK7.zip',
    sourcePath                => '/software',
    require                   => Class['wget'],
    before                    => Class['orawls::weblogic'],
  }

  exec { 'patch java to log all executions on $title':
    command =>
      "/bin/mv ${title} ${title}_ && /bin/cp /vagrant/puppet/files/java_debug ${title} && /bin/chmod +x ${title}",
    unless  => "/usr/bin/test -f ${title}_",
  }

  $default_bsu_params = { require => Resource['orawls::weblogic'] }
  $bsu_instances = hiera('bsu_instances', {})
  create_resources('orawls::bsu',$bsu_instances, $default_bsu_params)

  $default_fmw_params = { require => Resource['orawls::bsu'] }
  $fmw_installations = hiera('fmw_installations', {})
  create_resources('orawls::fmw',$fmw_installations, $default_fmw_params)

  $default_opatch_params = { require => Resource['orawls::fmw'] }
  $opatch_instances = hiera('opatch_instances', {})
  create_resources('orawls::opatch', $opatch_instances, $default_opatch_params)

  $default_domain_params = { require => Resource['orawls::opatch'] }

  $domain_instances = hiera('domain_instances', {})
  create_resources('orawls::domain', $domain_instances, $default_domain_params)

  $file_domain_libs = hiera('file_domain_libs', {})
  create_resources('file', $file_domain_libs, $default_domain_params)

  $wls_setting_instances = hiera('wls_setting_instances', {})
  create_resources('wls_setting', $wls_setting_instances,
    $default_domain_params)

  $default_nodemanager_params = { require => Resource['orawls::domain'] }

  $nodemanager_instances = hiera('nodemanager_instances', {})
  create_resources('orawls::nodemanager', $nodemanager_instances,
    $default_nodemanager_params)

  $version = hiera('wls_version')

  orautils::nodemanagerautostart{'autostart weblogic 11g':
    version                 => $version,
    wlHome                  => hiera('wls_weblogic_home_dir'),
    user                    => hiera('wls_os_user'),
    jsseEnabled             => hiera('wls_jsse_enabled'             ,false),
    customTrust             => hiera('wls_custom_trust'             ,false),
    trustKeystoreFile       => hiera('wls_trust_keystore_file'      ,undef),
    trustKeystorePassphrase => hiera('wls_trust_keystore_passphrase',undef),
    require                 => Resource['orawls::domain'],
  }
  
  $default_control_params = {
    require => [
      Resource['orawls::nodemanager'],
      Resource['orautils::nodemanagerautostart']
    ],
  }

  $control_instances = hiera('control_instances', {})
  create_resources('orawls::control', $control_instances,
    $default_control_params)
  
  $default_storeuserconfig_params = { require => Resource['orawls::control'] }
  
  $userconfig_instances = hiera('userconfig_instances', {})
  create_resources('orawls::storeuserconfig', $userconfig_instances,
    $default_storeuserconfig_params)

  $default_security_params = { require => Resource['orawls::storeuserconfig'] }
  $user_instances = hiera('user_instances', {})
  create_resources('wls_user', $user_instances, $default_security_params)

  $group_instances = hiera('group_instances', {})
  create_resources('wls_group', $group_instances, $default_security_params)

  $authentication_provider_instances =
    hiera('authentication_provider_instances', {})
  create_resources('wls_authentication_provider',
    $authentication_provider_instances, $default_security_params)

  $identity_asserter_instances = hiera('identity_asserter_instances', {})
  create_resources('wls_identity_asserter', $identity_asserter_instances,
    $default_security_params)
    
  $default_basic_config_params = {}

  $wls_domain_instances = hiera('wls_domain_instances', {})
  create_resources('wls_domain', $wls_domain_instances,
    $default_basic_config_params)

  # subscribe on domain changes
  $wls_adminserver_instances_domain =
    hiera('wls_adminserver_instances_domain', {})
  create_resources('wls_adminserver', $wls_adminserver_instances_domain,
    $default_basic_config_params)

  $machines_instances = hiera('machines_instances', {})
  create_resources('wls_machine', $machines_instances,
    $default_basic_config_params)

  $server_instances = hiera('server_instances', {})
  create_resources('wls_server', $server_instances,
    $default_basic_config_params)

  # subscribe on server changes
  $wls_adminserver_instances_server =
    hiera('wls_adminserver_instances_server', {})
  create_resources('wls_adminserver', $wls_adminserver_instances_server,
    $default_basic_config_params)

  $server_channel_instances = hiera('server_channel_instances', {})
  create_resources('wls_server_channel', $server_channel_instances,
    $default_basic_config_params)

  $cluster_instances = hiera('cluster_instances', {})
  create_resources('wls_cluster', $cluster_instances,
    $default_basic_config_params)

  $coherence_cluster_instances = hiera('coherence_cluster_instances', {})
  create_resources('wls_coherence_cluster', $coherence_cluster_instances,
    $default_basic_config_params)

  $server_template_instances = hiera('server_template_instances', {})
  create_resources('wls_server_template', $server_template_instances,
    $default_params)

  $mail_session_instances = hiera('mail_session_instances', {})
  create_resources('wls_mail_session', $mail_session_instances,
    $default_basic_config_params)
  
  $default_datasource_params = {
    require => [
      Resource['wls_domain'],
      Resource['wls_adminserver'],
      Resource['wls_machine'],
      Resource['wls_server'],
      Resource['wls_adminserver'],
      Resource['wls_server_channel'],
      Resource['wls_cluster'],
      Resource['wls_coherence_cluster'],
      Resource['wls_server_template'],
      Resource['wls_mail_session'],
    ],
  }
  
  $datasource_instances = hiera('datasource_instances', {})
  create_resources('wls_datasource', $datasource_instances,
    $default_datasource_params)

  $multi_datasource_instances = hiera('multi_datasource_instances', {})
  create_resources('wls_multi_datasource', $multi_datasource_instances,
    $default_datasource_params)
  
  $default_virtual_hosts_params = {
    require => [
      Resource['wls_datasource'],
      Resource['wls_multi_datasource'],
    ],
  }
  
  $virtual_host_instances = hiera('virtual_host_instances', {})
  create_resources('wls_virtual_host', $virtual_host_instances,
    $default_virtual_hosts_params)
  
  $default_workmanager_params = {
    require => [
      Resource['wls_virtual_host'],
    ],
  }

  $workmanager_constraint_instances =
    hiera('workmanager_constraint_instances', {})
  create_resources('wls_workmanager_constraint',
    $workmanager_constraint_instances, $default_workmanager_params)

  $workmanager_instances = hiera('workmanager_instances', {})
  create_resources('wls_workmanager', $workmanager_instances,
    $default_workmanager_params)
  
  $default_persistence_params = {
    require => [
      Resource['wls_workmanager_constraint'],
      Resource['wls_workmanager'],
    ],
  }

  $file_persistence_folders = hiera('file_persistence_folders', {})
  create_resources('file', $file_persistence_folders,
    $default_persistence_params)

  $file_persistence_store_instances =
    hiera('file_persistence_store_instances', {})
  create_resources('wls_file_persistence_store',
    $file_persistence_store_instances, $default_persistence_params)
  
  $default_jms_params = {
    require => [
      Resource['wls_file_persistence_store'],
    ],
  }
  
  $jmsserver_instances = hiera('jmsserver_instances', {})
  create_resources('wls_jmsserver', $jmsserver_instances, $default_jms_params)

  $jms_module_instances = hiera('jms_module_instances', {})
  create_resources('wls_jms_module', $jms_module_instances, $default_jms_params)

  $jms_subdeployment_instances = hiera('jms_subdeployment_instances', {})
  create_resources('wls_jms_subdeployment', $jms_subdeployment_instances,
    $default_jms_params)

  $jms_quota_instances = hiera('jms_quota_instances', {})
  create_resources('wls_jms_quota', $jms_quota_instances, $default_jms_params)

  $jms_connection_factory_instances =
    hiera('jms_connection_factory_instances', {})
  create_resources('wls_jms_connection_factory',
    $jms_connection_factory_instances, $default_jms_params)

  $jms_queue_instances = hiera('jms_queue_instances', {})
  create_resources('wls_jms_queue', $jms_queue_instances, $default_jms_params)

  $jms_topic_instances = hiera('jms_topic_instances', {})
  create_resources('wls_jms_topic', $jms_topic_instances, $default_jms_params)

  $foreign_server_instances = hiera('foreign_server_instances', {})
  create_resources('wls_foreign_server', $foreign_server_instances,
    $default_jms_params)

  $foreign_server_object_instances =
    hiera('foreign_server_object_instances', {})
  create_resources('wls_foreign_server_object',
    $foreign_server_object_instances, $default_jms_params)

  $safagent_instances = hiera('safagent_instances', {})
  create_resources('wls_safagent', $safagent_instances, $default_jms_params)

  $saf_remote_context_instances = hiera('saf_remote_context_instances', {})
  create_resources('wls_saf_remote_context', $saf_remote_context_instances,
    $default_jms_params)

  $saf_error_handler_instances = hiera('saf_error_handler_instances', {})
  create_resources('wls_saf_error_handler', $saf_error_handler_instances,
    $default_jms_params)

  $saf_imported_destination_instances =
    hiera('saf_imported_destination_instances', {})
  create_resources('wls_saf_imported_destination',
    $saf_imported_destination_instances, $default_jms_params)

  $saf_imported_destination_object_instances =
    hiera('saf_imported_destination_object_instances', {})
  create_resources('wls_saf_imported_destination_object',
    $saf_imported_destination_object_instances, $default_jms_params)
  
  $default_pack_domain_params = {
    require => [
      Resource['wls_jmsserver'],
      Resource['wls_jms_module'],
      Resource['wls_jms_subdeployment'],
      Resource['wls_jms_quota'],
      Resource['wls_jms_connection_factory'],
      Resource['wls_jms_queue'],
      Resource['wls_jms_topic'],
      Resource['wls_foreign_server'],
      Resource['wls_foreign_server_object'],
      Resource['wls_safagent'],
      Resource['wls_saf_remote_context'],
      Resource['wls_saf_error_handler'],
      Resource['wls_saf_imported_destination'],
      Resource['wls_saf_imported_destination_object'],
    ],
  }
  $pack_domain_instances =
    hiera('pack_domain_instances', $default_pack_domain_params)
  create_resources('orawls::packdomain', $pack_domain_instances,
    $default_pack_domain_params)
  
  $default_deployments_params = {
    require => [
      Resource['orawls::packdomain'],
    ],
  }
  
  $deployment_instances =
    hiera('deployment_instances', $default_deployments_params)
  create_resources('wls_deployment', $deployment_instances,
    $default_deployments_params)
}
