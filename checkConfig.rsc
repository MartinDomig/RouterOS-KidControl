# Scan the ARP table for changes
:global arpTable
:local arpTableNew [/ip arp print as-value]

:if ($arpTable != $arpTableNew) do={
  :put "ARP table changed"
  :set arpTable $arpTableNew

  /system script run onArpUpdate
}

# Test if kid control config changed
:global kidControl
:local kidControlNew [/ip kid-control print as-value]

:if ($kidControl != $kidControlNew) do={
  :put "Kid control config changed"
  :set kidControl $kidControlNew

  /system script run onKidControlUpdate
}
