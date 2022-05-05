需更新至Win11版本,wsl約佔70GB容量

# Script附檔內容
portfowarding.ps1 為 設置portproxy 和firewall
startWSL.ps1 為 將wsl內的bond0 mac address設置為Host機mac address,及啟動WSL. (需自行更改ubuntu_password密碼)

# 安裝WSL2
1.以系統管理員打開CMD

2.輸入wsl --install -d Ubuntu-20.04

3.等待進度完成後重開機,會自動跳出後續設定Ubuntu帳密步驟

4.設定完後,即安裝完成

5.安裝完WSL後,Win11需要更新(必要)[Windows Download the Linux kernel update package](https://docs.microsoft.com/en-us/windows/wsl/install-manual#step-4---download-the-linux-kernel-update-package)

6.開啟Powershell 輸入 Set-ExecutionPolicy RemoteSigned(之後啟script檔不用手動確認)

7.完成

# 安裝Docker在WSL2裡
1.[在wsl2 distro內安裝docker](https://docs.docker.com/engine/install/ubuntu/)

請參照Install using the convenience script,原生linux安装docker以script方式安裝
```
curl -fsSL https://get.docker.com -o get-docker.sh
sudo sh get-docker.sh
sudo service docker start
```
不可走一般docker安裝方式,因wsl裡未支援systemMd

2.[docker-compose為正常安裝步驟](https://docs.docker.com/compose/install/)

此處使用standalone binary on Linux systems安裝docker-compose
```
curl -SL https://github.com/docker/compose/releases/download/v2.5.0/docker-compose-linux-x86_64 -o /usr/local/bin/docker-compose
sudo chmod +x /usr/local/bin/docker-compose
```

# 重新安裝SSH在WSL2裡(如需用到container內ssh Host情況)
1.[需要在distro重新安裝openssh-server](https://blog.csdn.net/hxc2101/article/details/113617870)

```
sudo apt purge -y openssh-server
sudo apt install -y openssh-server
sudo service ssh restart
```
# 設置WSL開機時自動啟用docker & ssh功能
1.加入boot docker service

```
# Set a command to run when a new WSL instance launches. This example starts the Docker container service.
[boot]
command = service docker start && service ssh start
```

# 將WSL內localhost portforward至Host機
1.需要設portproxy 和firewall(已寫成script檔: portfowarding.ps1)

```
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

```

# 額外須知
1.在wsl中啟用之docker-compose 需將 /dev/dri 拿掉




# Windows on VMWare 安裝WSL2須知
[Vmware Import&Export machines](https://us.informatiweb-pro.net/virtualization/vmware/vmware-workstation-15-export-and-import-vms--2.html)

1.需安裝**VMWare workstation 16 pro以上**
安裝時**勾選自動安裝Windows Hypervisor Platform**

2.需要從host機的**新增選用功能**中的**更多windows功能**
**關閉**
Hyper-V
Windows Hypervision 平台
Windows 子系統Linux版
**開啟**
虛擬機器平台

3.VMWare中的虛擬機器需安裝Win11,並於設定中的CPU開啟選項Virtualize Inter VT-x/EPT or AMD-V/RVI

4.後續則為一般WSL2安裝過程

[WSL2 build USB/Bluetooth kernal](https://github.com/dorssel/usbipd-win/wiki/WSL-support#building-your-own-usbip-enabled-wsl-2-kernel)