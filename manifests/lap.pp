# Profile for standard LAP (Linux Apache PHP) server.
class profile::lap {
   include ::profile

   package {'libc-client':}
   package {'libmcrypt':}
   package {'nitc-php':}
   package {'nitc-php-bcmath':}
   package {'nitc-php-cli':}
   package {'nitc-php-common':}
   package {'nitc-php-dba':}
   package {'nitc-php-debuginfo':}
   package {'nitc-php-devel':}
   package {'nitc-php-embedded':}
   package {'nitc-php-enchant':}
   package {'nitc-php-fpm':}
   package {'nitc-php-gd':}
   package {'nitc-php-imap':}
   package {'nitc-php-intl':}
   package {'nitc-php-ldap':}
   package {'nitc-php-mbstring':}
   package {'nitc-php-mcrypt':}
   package {'nitc-php-mssql':}
   package {'nitc-php-mysql':}
   package {'nitc-php-mysqlnd':}
   package {'nitc-php-oci8':}
   package {'nitc-php-odbc':}
   package {'nitc-php-pdo':}
   package {'nitc-php-pgsql':}
   package {'nitc-php-process':}
   package {'nitc-php-pspell':}
   package {'nitc-php-snmp':}
   package {'nitc-php-soap':}
   package {'nitc-php-tidy':}
   package {'nitc-php-xml':}
   package {'nitc-php-xmlrpc':}
   package {'unixODBC':}
   package {'oracle-instantclient12.1-basic':}
   package {'oracle-instantclient12.1-devel':}
   package {'oracle-instantclient12.1-jdbc':}
   package {'oracle-instantclient12.1-odbc':}
   package {'oracle-instantclient12.1-sqlplus':}
   package {'oracle-instantclient12.1-tools':}

   firewall { '100 allow http and https access':
     port   => [80, 443],
     proto  => tcp,
     action => accept,
   }

}
