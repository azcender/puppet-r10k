# one machine setup with weblogic 10.3.6 with BSU
# needs jdk7, orawls, orautils, fiddyspence-sysctl, erwbgy-limits puppet modules

class profile::oracle_weblogic (
) {
  include ::profile

}
