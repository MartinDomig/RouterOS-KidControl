:global kidControlStreaming

:foreach i in=[/ip kid-control find disabled=yes] do={
  :local userName [/ip kid-control get $i name]

  /ip firewall mangle remove [/ip firewall mangle find comment="Mark packets from $userName"]
  /ip firewall mangle remove [/ip firewall mangle find comment="Mark packets to $userName"]

  /queue simple remove [/queue simple find name=$userName]
}

:foreach i in=[/ip kid-control find disabled=no] do={
  :local userName [/ip kid-control get $i name]

  # Skip userName "System"
  :if ($userName != "System") do={
    :put ("Creating queue for $userName")

    :if ([/ip firewall mangle find comment="Mark packets from $userName"] = "") do={
      /ip firewall mangle add chain=forward src-address-list=$userName action=mark-packet new-packet-mark=$userName passthrough=yes comment="Mark packets from $userName"
      /ip firewall mangle add chain=forward dst-address-list=$userName action=mark-packet new-packet-mark=$userName passthrough=yes comment="Mark packets to $userName"
    }

    :if ([/queue simple find name=$userName] = "") do={
      :local queueLimitNormal ($kidControlStreaming->"queueLimitNormal")
      /queue simple add name=$userName packet-marks=$userName target=10.0.0.0/24 max-limit="$queueLimitNormal/$queueLimitNormal"
    }
  }
}
