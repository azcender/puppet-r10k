# Install git
#

class profile::git {
  include ::profile
  class{ '::git': }
}
