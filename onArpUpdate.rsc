# This script creates an address list for each user in the Kid Control list.
# The address list contains the IP addresses of all devices associated with that user.

:foreach i in=[/ip kid-control find disabled=yes] do={
  :local userName [/ip kid-control get $i name]
  /ip firewall address-list remove [find list=$userName]
  /queue simple remove [find name=$userName]
}

:foreach i in=[/ip kid-control find disabled=no] do={
  :local userName [/ip kid-control get $i name]
  :put ("User $userName has devices:")

  # delete the address list for this user
  /ip firewall address-list remove [find list=$userName]

  :foreach j in=[/ip kid-control device find where user=$userName] do={
    :local deviceName [/ip kid-control device get $j name]
    :local macAddress [/ip kid-control device get $j mac-address]

    # check if the MAC address exists in the ARP table
    :if ([:len [/ip arp find where mac-address=$macAddress]] > 0) do={
      # get the IP address from the ARP table
      :local ipAddress [/ip arp get [find mac-address=$macAddress] address]
      :put ("  $deviceName, $macAddress, $ipAddress")

      # if username is System, skip adding to address list
      :if ($userName != "System") do={
        # add the IP address to the address list
        /ip firewall address-list add list=$userName address=$ipAddress
      }
    } else={
      :put ("  $deviceName, $macAddress, No IP found in ARP table")
    }
  }
}
