# hardware_platform.rb
require 'json'

Facter.add('candy') do
  setcode do
    containers  = []
    inspections = {}

    interfaces  = `docker ps`

    # the 'interfaces' fact returns a single comma-delimited string, e.g., "lo0,eth0,eth1"
    interfaces_array = interfaces.split("\n")

    interfaces_array.shift

    interfaces_array.each do |interface|
      containers << interface.split(' ')[0]
    end

    containers.each do |container|
      inspection = {}
      nextEntry = {}
      _ports = []

      ip = `docker inspect #{container}`
      nextEntry =  JSON.parse(ip)

      ports = nextEntry[0]["NetworkSettings"]["Ports"]

      ports.each do |port|
        _ports << port[0].split('/')[0]
      end

      inspection["server_names"] = nextEntry[0]["Config"]["Hostname"]
      inspection["ipaddresses"]  = nextEntry[0]["NetworkSettings"]["IPAddress"]
      inspection["ports"]        = _ports
      # inspection["name"]         = nextEntry[0]["Config"]["Hostname"]


      # inspections << inspection
      inspections[inspection["server_names"]] = inspection
    end

    inspections
  end
end
