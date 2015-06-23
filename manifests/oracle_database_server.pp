#
class profile::oracle_database_server (

  $augeas,
  $files,
  $file_lines,

) {

  # Create augesus resources
  create_resources(augeas, $augeas)

  # Create file resources
  create_resources(file, $files)

  # Create file_lines resources
  create_resources(file_line, $file_lines)


}
