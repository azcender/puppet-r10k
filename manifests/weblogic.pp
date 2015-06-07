# test
#
# one machine setup with weblogic 10.3.6 with BSU
# needs jdk7, orawls, orautils, fiddyspence-sysctl, erwbgy-limits puppet modules
#

class profile::weblogic (
  $augeas,
  $files,
) {

  # Execute augesus for weblogic
  create_resources(augeas, $augeas)

  # Create file resources
  create_resources(file, $files)

  # Create a software directory for install files
  file { '/software':
    ensure => directory,
  }

  # Fetch install media from a download location
  # TODO: Move to organization specific location
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

  # Remove any openjdk files
  $remove = [ 'java-1.7.0-openjdk.x86_64', 'java-1.6.0-openjdk.x86_64' ]

  package { $remove:
    ensure  => absent,
  }

  # TODO: Move jdk version to Hiera
  $java_version = 'jdk1.7.0_55'

  # Instdall JDK 7
  jdk7::install7{ $java_version :
    version                   => '7u55' ,
    fullVersion               => $java_version,
    alternativesPriority      => 18000,
    x64                       => true,
    downloadDir               => '/var/tmp/install',
    urandomJavaFix            => true,
    rsakeySizeFix             => true,
    cryptographyExtensionFile => 'UnlimitedJCEPolicyJDK7.zip',
    sourcePath                => '/software',
    require                   => Class['wget']
  }

  # Ensure Java is installed before orawls
  Jdk7::Install7[$java_version] -> Class[orawls::weblogic]

  include ::orawls::weblogic

  # Create domains
  $default_params = { require => Class[orawls::weblogic] }

  $domain_instances = hiera('domain_instances', {})
  create_resources(orawls::domain, $domain_instances, $default_params)

  $file_domain_libs = hiera('file_domain_libs', {})
  create_resources(file, $file_domain_libs, $default_params)

  $wls_setting_instances = hiera('wls_setting_instances', {})
  create_resources(wls_setting, $wls_setting_instances, $default_params)

  $default_params_nodemanager = {
    require => [Orawls::Domain[$domain_instances],
                File[$file_domain_libs],
                Wls_setting[$wls_setting_instances]],
  }
  
  $nodemanager_instances = hiera('nodemanager_instances', {})
  create_resources('orawls::nodemanager', $nodemanager_instances,
    $default_params_nodemanager)

  $version = hiera('wls_version')

  orautils::nodemanagerautostart{'autostart weblogic 11g':
    version                 => $version,
    wlHome                  => hiera('wls_weblogic_home_dir'),
    user                    => hiera('wls_os_user'),
    jsseEnabled             => hiera('wls_jsse_enabled'             ,false),
    customTrust             => hiera('wls_custom_trust'             ,false),
    trustKeystoreFile       => hiera('wls_trust_keystore_file'      ,undef),
    trustKeystorePassphrase => hiera('wls_trust_keystore_passphrase',undef),
  }
  
  $default_params_startwls = {
    require => Orawls::Nodemanager[default_params_nodemanager],
  }
  
  $control_instances = hiera('control_instances', {})
  create_resources('orawls::control',$control_instances, $default_params)
  
  #
  ## log all java executions:
  #define javaexec_debug() {
  #  exec { "patch java to log all executions on $title":
  #    command => "/bin/mv ${title} ${title}_ && /bin/cp /vagrant/puppet/files/java_debug ${title} && /bin/chmod +x ${title}",
  #    unless  => "/usr/bin/test -f ${title}_",
  #  }
  #}
  #
  #
  #class bsu{
  #  require orawls::weblogic
  #  $default_params = {}
  #  $bsu_instances = hiera('bsu_instances', {})
  #  create_resources('orawls::bsu',$bsu_instances, $default_params)
  #}
  #
  #class fmw{
  #  require bsu
  #  $default_params = {}
  #  $fmw_installations = hiera('fmw_installations', {})
  #  create_resources('orawls::fmw',$fmw_installations, $default_params)
  #}
  #
  #class opatch{
  #  require fmw,bsu,orawls::weblogic
  #  $default_params = {}
  #  $opatch_instances = hiera('opatch_instances', {})
  #  create_resources('orawls::opatch',$opatch_instances, $default_params)
  #}
  #
  #
  #class userconfig{
  #  require orawls::weblogic, domains, nodemanager, startwls
  #  $default_params = {}
  #  $userconfig_instances = hiera('userconfig_instances', {})
  #  create_resources('orawls::storeuserconfig',$userconfig_instances, $default_params)
  #}
  #
  #class security{
  #  require userconfig
  #  $default_params = {}
  #  $user_instances = hiera('user_instances', {})
  #  create_resources('wls_user',$user_instances, $default_params)
  #
  #  $group_instances = hiera('group_instances', {})
  #  create_resources('wls_group',$group_instances, $default_params)
  #
  #  $authentication_provider_instances = hiera('authentication_provider_instances', {})
  #  create_resources('wls_authentication_provider',$authentication_provider_instances, $default_params)
  #
  #  $identity_asserter_instances = hiera('identity_asserter_instances', {})
  #  create_resources('wls_identity_asserter',$identity_asserter_instances, $default_params)
  #
  #}
  #
  #class basic_config{
  #  require security
  #  $default_params = {}
  #
  #  $wls_domain_instances = hiera('wls_domain_instances', {})
  #  create_resources('wls_domain',$wls_domain_instances, $default_params)
  #
  #  # subscribe on domain changes
  #  $wls_adminserver_instances_domain = hiera('wls_adminserver_instances_domain', {})
  #  create_resources('wls_adminserver',$wls_adminserver_instances_domain, $default_params)
  #
  #  $machines_instances = hiera('machines_instances', {})
  #  create_resources('wls_machine',$machines_instances, $default_params)
  #
  #  $server_instances = hiera('server_instances', {})
  #  create_resources('wls_server',$server_instances, $default_params)
  #
  #  # subscribe on server changes
  #  $wls_adminserver_instances_server = hiera('wls_adminserver_instances_server', {})
  #  create_resources('wls_adminserver',$wls_adminserver_instances_server, $default_params)
  #
  #  $server_channel_instances = hiera('server_channel_instances', {})
  #  create_resources('wls_server_channel',$server_channel_instances, $default_params)
  #
  #  $cluster_instances = hiera('cluster_instances', {})
  #  create_resources('wls_cluster',$cluster_instances, $default_params)
  #
  #  $coherence_cluster_instances = hiera('coherence_cluster_instances', {})
  #  create_resources('wls_coherence_cluster',$coherence_cluster_instances, $default_params)
  #
  #  $server_template_instances = hiera('server_template_instances', {})
  #  create_resources('wls_server_template',$server_template_instances, $default_params)
  #
  #  $mail_session_instances = hiera('mail_session_instances', {})
  #  create_resources('wls_mail_session',$mail_session_instances, $default_params)
  #
  #}
  #
  #class datasources{
  #  require basic_config
  #  $default_params = {}
  #  $datasource_instances = hiera('datasource_instances', {})
  #  create_resources('wls_datasource',$datasource_instances, $default_params)
  #
  #  $multi_datasource_instances = hiera('multi_datasource_instances', {})
  #  create_resources('wls_multi_datasource',$multi_datasource_instances, $default_params)
  #
  #}
  #
  #
  #class virtual_hosts{
  #  require datasources
  #  $default_params = {}
  #  $virtual_host_instances = hiera('virtual_host_instances', {})
  #  create_resources('wls_virtual_host',$virtual_host_instances, $default_params)
  #}
  #
  #class workmanagers{
  #  require virtual_hosts
  #  $default_params = {}
  #
  #  $workmanager_constraint_instances = hiera('workmanager_constraint_instances', {})
  #  create_resources('wls_workmanager_constraint',$workmanager_constraint_instances, $default_params)
  #
  #  $workmanager_instances = hiera('workmanager_instances', {})
  #  create_resources('wls_workmanager',$workmanager_instances, $default_params)
  #}
  #
  #class file_persistence{
  #  require workmanagers
  #
  #  $default_params = {}
  #
  #  $file_persistence_folders = hiera('file_persistence_folders', {})
  #  create_resources('file',$file_persistence_folders, $default_params)
  #
  #  $file_persistence_store_instances = hiera('file_persistence_store_instances', {})
  #  create_resources('wls_file_persistence_store',$file_persistence_store_instances, $default_params)
  #}
  #
  #class jms{
  #  require file_persistence
  #
  #  $default_params = {}
  #  $jmsserver_instances = hiera('jmsserver_instances', {})
  #  create_resources('wls_jmsserver',$jmsserver_instances, $default_params)
  #
  #  $jms_module_instances = hiera('jms_module_instances', {})
  #  create_resources('wls_jms_module',$jms_module_instances, $default_params)
  #
  #  $jms_subdeployment_instances = hiera('jms_subdeployment_instances', {})
  #  create_resources('wls_jms_subdeployment',$jms_subdeployment_instances, $default_params)
  #
  #  $jms_quota_instances = hiera('jms_quota_instances', {})
  #  create_resources('wls_jms_quota',$jms_quota_instances, $default_params)
  #
  #  $jms_connection_factory_instances = hiera('jms_connection_factory_instances', {})
  #  create_resources('wls_jms_connection_factory',$jms_connection_factory_instances, $default_params)
  #
  #  $jms_queue_instances = hiera('jms_queue_instances', {})
  #  create_resources('wls_jms_queue',$jms_queue_instances, $default_params)
  #
  #  $jms_topic_instances = hiera('jms_topic_instances', {})
  #  create_resources('wls_jms_topic',$jms_topic_instances, $default_params)
  #
  #  $foreign_server_instances = hiera('foreign_server_instances', {})
  #  create_resources('wls_foreign_server',$foreign_server_instances, $default_params)
  #
  #  $foreign_server_object_instances = hiera('foreign_server_object_instances', {})
  #  create_resources('wls_foreign_server_object',$foreign_server_object_instances, $default_params)
  #
  #  $safagent_instances = hiera('safagent_instances', {})
  #  create_resources('wls_safagent',$safagent_instances, $default_params)
  #
  #  $saf_remote_context_instances = hiera('saf_remote_context_instances', {})
  #  create_resources('wls_saf_remote_context',$saf_remote_context_instances, $default_params)
  #
  #  $saf_error_handler_instances = hiera('saf_error_handler_instances', {})
  #  create_resources('wls_saf_error_handler',$saf_error_handler_instances, $default_params)
  #
  #  $saf_imported_destination_instances = hiera('saf_imported_destination_instances', {})
  #  create_resources('wls_saf_imported_destination',$saf_imported_destination_instances, $default_params)
  #
  #  $saf_imported_destination_object_instances = hiera('saf_imported_destination_object_instances', {})
  #  create_resources('wls_saf_imported_destination_object',$saf_imported_destination_object_instances, $default_params)
  #}
  #
  #class pack_domain{
  #  require jms
  #
  #  $default_params = {}
  #  $pack_domain_instances = hiera('pack_domain_instances', $default_params)
  #  create_resources('orawls::packdomain',$pack_domain_instances, $default_params)
  #}
  #
  #class deployments{
  #  require pack_domain
  #
  #  $default_params = {}
  #  $deployment_instances = hiera('deployment_instances', $default_params)
  #  create_resources('wls_deployment',$deployment_instances, $default_params)
  }
