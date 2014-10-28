# A wrapper that contains all thr functionality needed for a standard LAMP 
# server (Linux Apache MySQL PHP).

class profile::lamp inherits profile {

  include ::apache
  include ::apache::mod::php
  include ::mysql::server
  include ::mysql::bindings::php

}
