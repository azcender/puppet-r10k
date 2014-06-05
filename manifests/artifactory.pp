# Instantiates artifactory
class profiles::artifactory inherits profiles {
  class {'::artifactory': }
}
