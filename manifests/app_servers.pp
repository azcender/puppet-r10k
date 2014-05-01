class profiles::app_servers inherits profiles {

  define iterate_datasources($tomcat_name, $database_servername, $database_service, $database_username, $database_password, $database_connector, $database_port) {

    notify { "Evaluating ${tomcat_name}\\${name}": 
      require => Package["tomcat${tomcat::version}"],
    }

    case $database_connector {
      mysql: {
        $content = "    <Resource name=\"jdbc/${database_service}\"
              auth=\"Container\"
              type=\"javax.sql.DataSource\"
              description=\"MySQL Datasource\"
              username=\"${database_username}\"
              password=\"${database_password}\"
              driverClassName=\"com.mysql.jdbc.Driver\"
              description=\"MySQL Datasource\"
              url=\"jdbc:${database_connector}://${database_servername}:${database_port}/${database_service}\"
              maxActive=\"15\"
              maxIdle=\"3\"/>\n"
      }
      oracle: {
        $content = "    <Resource name=\"jdbc/${database_service}\" auth=\"Container\"
              type=\"oracle.jdbc.pool.OracleDataSource\"
              description=\"Oracle Datasource\"
              factory=\"oracle.jdbc.pool.OracleDataSourceFactory\"
              user=\"${database_username}\"
              password=\"${database_password}\"
              url=\"jdbc:${database_connector}:thin:@//${database_servername}:${database_port}/${database_service}\"
              connectionCachingEnabled=\"true\"
              connectionCacheName=\"CXCACHE\"
              connectionCacheProperties=\"{MaxStatementsLimit=5, MinLimit=1, MaxLimit=1, ValidateConnection=true}\"/>\n"
      }
      default: {
        fail("Unknown database (${database_connector}) supplied for ${name}")
      }
    }

    ensure_resource(
      'concat_fragment',
#     "server.xml_${tomcat_name}_globalnamingresources+${name}",
      "server.xml_${tomcat_name}+04_${name}_body1",
      {
        content => $content,
        require => Package["tomcat${tomcat::version}"],
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
