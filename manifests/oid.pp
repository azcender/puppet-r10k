# Lays foundation for Oracle ID for Forest Service
class profile::oid (
  $augeas,
  $files,
  $hosts,
  $file_lines,
) {

  # Execute augesus for weblogic
  create_resources(augeas, $augeas)

  # Create file resources
  create_resources(file, $files)

  # Create host resources
  create_resources(host, $hosts)

  # Create file lines
  create_resources(file_line, $file_lines)
}
