class profiles::app_servers inherits profiles {

  define iterate_datasources($tomcat_name, $database_servername, $database_service, $database_username, $database_password, $database_connector, $database_port) {
    notify { "******** evaluating ${tomcat_name}\\${name}": 
      require => Package["tomcat${tomcat::version}"],
    }
    ensure_resource(
      'concat_fragment',
      "server.xml_${tomcat_name}_globalnamingresources+${name}",
      {
        content => '        <Resource name="jdbc/[$database_service]" auth="Container"
           type="oracle.jdbc.pool.OracleDataSource"
           description="Oracle Datasource"
           factory="oracle.jdbc.pool.OracleDataSourceFactory"
           url="jdbc:${database_connector}:thin:@//${database_servername}:${database_port}/${database_service}"
           user="${database_username}"
           password="${database_password}"
           connectionCachingEnabled="true"
           connectionCacheName="CXCACHE"
           connectionCacheProperties="{MaxStatementsLimit=5, MinLimit=1, MaxLimit=1, ValidateConnection=true}"
           />
        ',
      }
    )
  }

  # Hiera lookups
  $instances = hiera('profiles::app_servers::instances')
  $apps = hiera('profiles::app_servers::apps')
  $datasources = hiera('profiles::app_servers::datasources')

  include ::tomcat

  create_resources('tomcat::instance', $instances)
  create_resources('wget::fetch', $apps)
  create_resources( iterate_datasources, $datasources )

}
