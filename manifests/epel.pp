# Installs the epel "Extra Packages" repository
class profile::epel {
  Yumrepo<||> -> Package<||>

  class{ '::epel': }
}
