# Setup default package provider to chocolatey on Windows nodes
class profile::chocolatey {
  include ::profile

  Package { provider => chocolatey }
}
