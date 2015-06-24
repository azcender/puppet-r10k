Facter.add(:shmall) do
  setcode do
    mem_bytes = Facter::Util::Resolution.exec("free -b | sed -n 2p | awk '{ print $2 }'").to_i / 2
    mem_bytes / Facter::Util::Resolution.exec("getconf PAGESIZE").to_i
  end
end
