# Installs the epel "Extra Packages" repository
class profile::epel inherits profile {
  Yumrepo<||> -> Package<||>

  class{ '::epel': }
}
