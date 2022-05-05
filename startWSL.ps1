$ubuntu_password=admin
$activate_mac=Get-NetRoute -DestinationPrefix '0.0.0.0/0' | Get-NetAdapter
$mac_address=$activate_mac.macaddress.replace('-',':')

wsl echo $ubuntu_password `| sudo -S ip link set dev bond0 address $mac_address
wsl -d Ubuntu-20.04