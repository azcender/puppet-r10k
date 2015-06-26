# Sets up the base oracle build
class profile::oracle_foundation (
  $augeas,
  $users,
  $files,
  $groups,
  $packages,
  $concats,
  $concat_fragments,
  $operatingsystemmajrelease_max,   # need to make hierarchy
  $operatingsystemmajrelease_min,   # need to make hierarchy
  $nfs_mount_sysinfra = undef,
  $nfs_mount_ops = undef,
  #  $::profile::fsdomain,
  ) {
    include ::profile

    # Basic validation of params
    validate_array($packages)

    validate_hash($augeas)
    validate_hash($files)
    validate_hash($users)
    validate_hash($groups)

    validate_numeric($operatingsystemmajrelease_min)
    validate_numeric($operatingsystemmajrelease_max)

    validate_string($nfs_mount_sysinfra)
    validate_string($nfs_mount_ops)


    case $::osfamily {
      'RedHat': {
        if ( $::operatingsystemmajrelease < $operatingsystemmajrelease_min ) or
        ($::operatingsystemmajrelease > $operatingsystemmajrelease_max ) {
          fail("Class['profile::oracle']: Unsupported operating system major release ${::operatingsystemmajrelease}. Requires ${operatingsystemmajrelease_max}")
        }
      }
      default: {
        fail("Class['profile::oracle']: Unsupported osfamily: ${::osfamily}")
      }
    }

    # Install packages needed for base Oracle build
    package { $packages: }

    # Manipulate complex files using augeas
    create_resources(augeas, $augeas)

    # Execute concat types
    create_resources(concat, $concats)

    # Execute concat fragemnts
    create_resources(concat::fragment, $concat_fragments)

    # Create files needed for base Oracle build
    create_resources(file, $files)

    # Create users needed for base Oracle build
    create_resources(user, $users)

    # Create groups needed for base Oracle build
    create_resources(group, $groups)
  }
