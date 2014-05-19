class profiles::yum inherits profiles {
  class {'yum':
    update => 'cron',
   }
}
