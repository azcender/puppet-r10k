# Setup default package provider to chocolatey on Windows nodes
class profile::chocolatey inherits profile {
  Package { provider => chocolatey }

}
