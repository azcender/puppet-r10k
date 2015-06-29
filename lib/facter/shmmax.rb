Facter.add(:shmmax) do
  setcode do
    Facter::Util::Resolution.exec("free -b | sed -n 2p | awk '{ print $2 }'").to_i / 2
  end
end
