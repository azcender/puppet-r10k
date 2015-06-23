# Sets up the base oracle build
class profile::oracle (
  $augeas,
  $files,
  $groups,
  $packages,
  $operatingsystemmajrelease_max,   # need to make hierarchy
  $operatingsystemmajrelease_min,   # need to make hierarchy
  $nfs_mount_sysinfra,
  $nfs_mount_ops,
#  $::profile::fsdomain,
) {
  include ::profile

  # Basic validation of params
  validate_array($packages)

  validate_hash($augeas)
  validate_hash($files)
  validate_hash($users)
  validate_hash($groups)
  validate_string($operatingsystemmajrelease_min)
  validate_string($nfs_mount_sysinfra)
  validate_string($nfs_mount_ops)

  ### Oracle Base Prereqs #################################

  ## Redhat Enterprise Linux 6.x with latest patchset (not RHEL 7)
  notify { "OSFAMILY ${osfamily}": }
  notify { "OPERATINGSYSTEMMAJRELEASE ${operatingsystemmajrelease}": }
  case $::osfamily {
    'RedHat': {
      if ( $::operatingsystemmajrelease < $operatingsystemmajrelease_min ) or ($::operatingsystemmajrelease > $operatingsystemmajrelease_max ) {
        fail("Class['profile::oracle']: Unsupported operating system major release ${::operatingsystemmajrelease}. Requires $operatingsystemmajrelease_max")
      }
    }
    default: {
      fail("Class['profile::oracle']: Unsupported osfamily: ${::osfamily}")
    }
  }

  ## 2.6.32-100.28.5.el6  - or greater
  notify { "KERNELMAJVERSION ${kernelmajversion}": }

  #Architecture x86 64 bit
  notify { "ARCHITECTURE ${architecture}": }

  ## Kernel settings:  kernel.shmmax - minimum 4294967295
  ## SELINUX and firewall disabled

  ## Disable IPv6 Networking  # what about Nitc???
  # Will interface resource work?
  # sysctl -a | grep net.ipv6.conf.all.disable_ipv6
  # file /etc/sysctl.conf, add line 'net.ipv6.conf.all.disable_ipv6 = 1'
  # run 'sysctl -p'

  # Disable requiretty
  # Hostnames must be in lowercase
  # TMP (/tmp):  2gb dedicated filesystem
  # unames??  

  # NFS mounts ????
  # still need to get domain prod or work
  #notify { "NFS_MOUNT ${nfs_mount_sysinfra}": }
  #exec { "Check_nfs_sysinfra":
  #  command => "grep $nfs_mount_sysinfra /etc/mtab",
  #  path    => "/usr/local/bin/:/bin/",
  #  logoutput    => "true",
  #}   
  #exec { "Check_nfs_ops":
  #  command => "grep $nfs_mount_ops /etc/mtab",
  #  path    => "/usr/local/bin/:/bin/",
  #  logoutput    => "true",
  #}

  # Confirm /etc/hosts 
  # ### use host resource
  #exec { "Check_hosts":
  #  command => "cat /etc/hosts",
  #  path    => "/usr/local/bin/:/bin/",
  #  logoutput    => "true",
  #}

  # end pre-reqs
  ####################################


  # Install packages needed for base Oracle build
  package { $packages: }

  # Manipulate complex files using augeas
  create_resources(augeas, $augeas)

  # Create files needed for base Oracle build
  create_resources(file, $files)

  # Create users needed for base Oracle build
  create_resources(user, $users)

  # Create groups needed for base Oracle build
  create_resources(group, $groups)
}
