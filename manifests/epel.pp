# Installs the epel "Extra Packages" repository
class profile::epel {
  include ::profile

  class{ '::epel': }
}
