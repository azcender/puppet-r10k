# RVM
class profile::rvm {
  include ::profile
  class{ '::rvm': }
}
