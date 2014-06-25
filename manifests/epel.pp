# Installs the epel "Extra Packages" repository
class profile::epel {
  class{ '::epel': }
}
