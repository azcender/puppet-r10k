# Instantiates artifactory
class profile::artifactory inherits profile {
  class {'::artifactory': }
}
