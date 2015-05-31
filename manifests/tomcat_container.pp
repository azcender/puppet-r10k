# A wrapper that contains all thr functionality needed for a standard java web
# application --- does not support JEE applications
node default {
  #  $maven_repo = hiera('profile::tomcat_container::maven_repo')

  #$groupId    = hiera('profile::tomcat_container::groupId')
  #$artifactId = hiera('profile::tomcat_container::artifactId')
  #$version    = hiera('profile::tomcat_container::version')
  #$packaging  = hiera('profile::tomcat_container::packaging')

  ## Validate Maven coordinates and other strings
  #validate_string($groupId)
  #validate_string($artifactId)
  #validate_string($version)
  #validate_string($maven_repo)

  #validate_re($packaging, [
  #              'war',
  #              'ear',
  #              'jar'
  #            ])

  #$_group_id = regsubst($groupId, '\.', '/', 'G')

  #$application_url =
  #  "${maven_repo}/${_group_id}/${artifactId}/${version}
  # /${artifactId}-${version}.${packaging}"

  #::tomcat::war { 'sample.war':
  #  war_source    => $application_url,
  #}

  # Remove examples
  file { '/usr/local/tomcat/webapps/examples':
    ensure => absent,
    force  => true,
  }

  # Remove favicon
  file { '/usr/local/tomcat/webapps/ROOT/favicon.ico':
    ensure => absent,
  }
}
