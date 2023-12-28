# This script puts IP addresses of devices in the address list of the user who is using the device.
# It is supposed to be used with the DHCP server.

/ip dhcp-server set [find name=dhcp1] lease-script=":if (\$leaseBound = \"0\") do={\
\n  /ip firewall address-list remove [find where address=\$leaseActIP]\
\n} else={\
\n  :local kidDevice [/ip kid-control device find where mac-address=\$leaseActMAC]\
\n  :if ([:len \$kidDevice] > 0) do={\
\n    :local kidUser [/ip kid-control device get \$kidDevice user]\
\n    :if (\$kidUser != \"System\") do={\
\n      /ip firewall address-list add list=\$kidUser address=\$leaseActIP\
\n    }\
\n  }\
\n}"
