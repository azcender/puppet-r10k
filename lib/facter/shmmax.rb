Facter.add(:shmmax) do
  setcode do
    # shmmax = Facter.value(:memorysize).to_i * 1024 * 1024 / 2
    shmmax = Facter::Util::Resolution.exec("free -b | sed -n 2p | awk '{ print $2 }'").to_i / 2
    shmmax
  end
end
