# hardware_platform.rb
require 'json'

Facter.add('candy') do
  setcode do
    containers = []
    inspections = []
    interfaces = `docker ps`
    #  interfaces = Facter.value(:interfaces)
    # the 'interfaces' fact returns a single comma-delimited string, e.g., "lo0,eth0,eth1"
    interfaces_array = interfaces.split("\n")

    interfaces_array.shift

    interfaces_array.each do |interface|
      containers << interface.split(' ')[0]

    end

    containers.each do |container|
      inspection = {}
      nextEntry = {}
      #ip = `docker inspect --format='{{.NetworkSettings.IPAddress}}' #{container}`
      ip = `docker inspect #{container}`
      nextEntry =  JSON.parse(ip)

      inspection["Hostname"] = nextEntry[0]["Config"]["Hostname"]
      inspection["IPAddress"] = nextEntry[0]["NetworkSettings"]["IPAddress"]
      inspection["Ports"] = nextEntry[0]["NetworkSettings"]["Ports"]


      inspections << inspection
    end

    inspections
  end
end
