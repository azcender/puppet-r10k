# A wrapper that contains all thr functionality needed for a standard java web
# application --- does not support JEE applications

class profile::jenkins_master {
  # Include base class
  include ::profile

  # Include standard jenkins class
  include ::jenkins
  include ::jenkins::master
  # The instances to be configured on this node
  $plugins = hiera('profile::jenkins_master::plugins')

  # The plugin default
  $plugin_default = {}

  create_resources('::jenkins::plugin', $plugins, $plugin_default)
}
