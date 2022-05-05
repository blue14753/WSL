if (!([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")) { Start-Process powershell.exe "-NoProfile -ExecutionPolicy Bypass -File `"$PSCommandPath`"" -Verb RunAs; exit }

$remoteaddress = bash.exe -c "ifconfig eth0 | grep 'inet '"
$found = $remoteaddress -match '\d{1,3}\.\d{1,3}\.\d{1,3}\.\d{1,3}';

if ($found) {
  $remoteaddress = $matches[0];
}
else {
  Write-Output "IP address could not be found";
  exit;
}

$address = "0.0.0.0"
$ports = @(80);

for ($i = 0; $i -lt $ports.length; $i++) {
  $port = $ports[$i];
  Invoke-Expression "netsh interface portproxy delete v4tov4 listenaddress=$address listenport=$port";
  Invoke-Expression "netsh advfirewall firewall delete rule name=$port";

  Invoke-Expression "netsh interface portproxy add v4tov4 listenaddress=$address listenport=$port connectaddress=$remoteaddress connectport=$port";
  Invoke-Expression "netsh advfirewall firewall add rule name=$port dir=in action=allow protocol=TCP localport=$port";
}

Invoke-Expression "netsh interface portproxy show v4tov4";


