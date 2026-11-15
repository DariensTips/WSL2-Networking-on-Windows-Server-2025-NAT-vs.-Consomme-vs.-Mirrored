# Command reference: WSL2 Networking on Windows Server 2025: NAT vs. Consomme vs. Mirrored

Author / channel: Darien Hawkins / Darien's Tips  
Source script: `WSLWNSVRNET_Title-Chapters-Script_20261114-225958.txt`  
Prepared: 2026-11-15  
Purpose: Read and copy individual reference examples in the video's sequence. This is not an end-to-end script.

Tested environment: The author reports WSL 3.0.5 with Fedora 45 on Windows Server 2025 and Windows 11 26H2; Server Core and Server 2022 observations are labeled in README.md. The package was not executed against a Windows/WSL lab during preparation.

**Replace all documentation addresses and hostnames before use. Do not run all files on one system.** Read README.md for prerequisites, browser tests, mode selections, and cleanup timing. Commands retain the source parameters, ports, variables, and behavior; no discovery loops, scheduled jobs, persistence helpers, or new automation are introduced.

## 1. Create the NAT test page, inspect networking, and start its foreground HTTP server.

File: [`01-nat-fedora.sh`](reference/01-nat-fedora.sh)  
Source section: B  
Target: Fedora 45 WSL2 distribution on Windows Server 2025  
Shell: Bash  
Privileges: Standard Linux user; no sudo in this example  
Prerequisites: WSL already installed; NAT selected and WSL restarted; Python 3 and writable home directory

```bash
myWebDir=~/wsl-web-demo

mkdir -p $myWebDir

cat > $myWebDir/index.html <<'EOF'
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <title>WSL2 Networking Demo</title>
</head>
<body>
    <h1>Hello, Viewers!</h1>
    <p>This page is served by Fedora 45 running in WSL2 on Windows Server 2025.</p>
    <p>The WSL2 networking mode is NAT.</p>
    <p><strong>Network Address Translation (NAT)</strong> is a networking mechanism that maps IP addresses between different address spaces by modifying the source or destination IP address in packet headers. It enables systems on a private network to communicate with external networks using translated addresses. </p>
</body>
</html>
EOF

wslinfo --networking-mode
ip a
python3 -m http.server 8000 --bind 0.0.0.0 --directory $myWebDir
```

## 2. Inspect the Windows adapters and compare the three TCP endpoints.

File: [`02-nat-windows-checks.ps1`](reference/02-nat-windows-checks.ps1)  
Source section: B  
Target: Windows Server 2025 WSL host  
Shell: Windows PowerShell  
Privileges: Standard user  
Prerequisites: NAT Fedora HTTP server from 01 is running on TCP 8000; replace both IP examples

```powershell
ipconfig

# Browser checks between these two command examples are listed in README.md.
$LocalIPs="172.30.96.25","127.0.0.1","192.0.2.10"
$LocalIPs | ForEach-Object {Test-NetConnection -ComputerName $_ -Port 8000}
```

## 3. Inspect mappings, configure TCP 9409 to 8000, and display the mapping.

File: [`03-nat-portproxy-add.ps1`](reference/03-nat-portproxy-add.ps1)  
Source section: C  
Target: Windows Server 2025 WSL host  
Shell: Windows PowerShell  
Privileges: Run as Administrator  
Prerequisites: NAT mode; Fedora listening on TCP 8000; current guest IP; unused host port 9409; IP Helper available

```powershell
netsh interface portproxy show all

$WslIPv4 = '172.30.96.25'
netsh interface portproxy add v4tov4 `
    listenaddress=192.0.2.10 `
    listenport=9409 `
    connectaddress=$WslIPv4 `
    connectport=8000 `
    protocol=tcp

netsh interface portproxy show all
```

## 4. Allow incoming TCP 9409 to the host address, as demonstrated.

File: [`04-nat-firewall-add.ps1`](reference/04-nat-firewall-add.ps1)  
Source section: C  
Target: Windows Server 2025 WSL host  
Shell: Windows PowerShell  
Privileges: Run as Administrator  
Prerequisites: Proxy from 03 is configured; no conflicting rule with this name

```powershell
New-NetFirewallRule `
    -Name 'WSL-Web-TCP9409' `
    -DisplayName 'WSL Web - TCP 9409 to 8000' `
    -Direction Inbound `
    -Action Allow `
    -Protocol TCP `
    -LocalAddress 192.0.2.10 `
    -LocalPort 9409 `
    -Profile Any
```

## 5. Remove only the demonstrated TCP proxy and named firewall rule.

File: [`05-nat-cleanup.ps1`](reference/05-nat-cleanup.ps1)  
Source section: C  
Target: Windows Server 2025 WSL host  
Shell: Windows PowerShell  
Privileges: Run as Administrator  
Prerequisites: Finish local and external HTTP tests first; listening address must match the created proxy

```powershell
netsh interface portproxy delete v4tov4 `
    listenaddress=192.0.2.10 `
    listenport=9409 `
    protocol=tcp

Remove-NetFirewallRule -Name 'WSL-Web-TCP9409'

netsh interface portproxy show all
```

## 6. Record host adapter addresses before launching Fedora.

File: [`06a-mirrored-windows-adapters.ps1`](reference/06a-mirrored-windows-adapters.ps1)  
Source section: D  
Target: Windows 11 26H2 WSL host  
Shell: Windows PowerShell  
Privileges: Standard user  
Prerequisites: Mirrored selected; Hyper-V Firewall enabled; changes applied; WSL shut down

```powershell
ipconfig /all
```

## 7. Create the Mirrored test page, inspect networking, and start its foreground HTTP server.

File: [`06-mirrored-fedora.sh`](reference/06-mirrored-fedora.sh)  
Source section: D  
Target: Fedora 45 WSL2 distribution on Windows 11 26H2  
Shell: Bash  
Privileges: Standard Linux user; no sudo in this example  
Prerequisites: WSL already installed; Mirrored selected and WSL restarted; Python 3 and writable home directory

```bash
myWebDir=~/wsl-web-demo

mkdir -p $myWebDir

cat > $myWebDir/index.html <<'EOF'
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <title>WSL2 Networking Demo</title>
</head>
<body>
    <h1>Hello, Viewers!</h1>
    <p>This page is served by Fedora 45 running in WSL2 on Windows 11 26H2.</p>
    <p>The WSL2 networking mode is Mirrored.</p>
    <p><strong>Mirrored networking</strong> is a WSL2 networking mode that mirrors the Windows host's network interfaces into the Linux environment. It enables direct access to Linux services from the local network without a manually configured port proxy, provided the application's listening settings and applicable firewall rules permit the connection. </p>
</body>
</html>
EOF

wslinfo --networking-mode
ip a
python3 -m http.server 7000 --bind 0.0.0.0 --directory $myWebDir
```

## 8. Allow TCP 7000 on the Windows 11 host, as demonstrated.

File: [`07-mirrored-firewall-add.ps1`](reference/07-mirrored-firewall-add.ps1)  
Source section: D  
Target: Windows 11 26H2 WSL host  
Shell: Windows PowerShell  
Privileges: Run as Administrator  
Prerequisites: Mirrored Fedora server from 06 is listening on TCP 7000; replace the Windows 11 address

```powershell
New-NetFirewallRule `
    -Name 'WSL-Web-TCP7000' `
    -DisplayName 'WSL Web - TCP 7000' `
    -Direction Inbound `
    -Action Allow `
    -Protocol TCP `
    -LocalAddress 192.0.2.20 `
    -LocalPort 7000 `
    -Profile Any
```

## 9. Inspect effective WSL Hyper-V firewall settings after the browser tests.

File: [`08-mirrored-hyperv-policy.ps1`](reference/08-mirrored-hyperv-policy.ps1)  
Source section: D  
Target: Windows 11 26H2 WSL host  
Shell: Windows PowerShell  
Privileges: Administrative session, as used in the demonstration  
Prerequisites: WSL Hyper-V firewall cmdlets available; do not substitute a machine-specific VM ID for the supplied WSL creator ID

```powershell
Get-NetFirewallHyperVVMSetting `
    -PolicyStore ActiveStore `
    -Name '{40E0AC32-46A5-438A-A0B2-2B479E8F2E90}' |
    Select-Object Enabled, AllowHostPolicyMerge, DefaultInboundAction
```

## 10. Remove the Windows 11 TCP 7000 demonstration firewall rule.

File: [`09-mirrored-cleanup.ps1`](reference/09-mirrored-cleanup.ps1)  
Source section: D  
Target: Windows 11 26H2 WSL host  
Shell: Windows PowerShell  
Privileges: Run as Administrator  
Prerequisites: Finish the Windows and Linux external browser tests first

```powershell
Remove-NetFirewallRule -Name 'WSL-Web-TCP7000'
```

## 11. Inspect the active networking mode and interfaces after the failed mirrored startup.

File: [`10-server-mirrored-check.sh`](reference/10-server-mirrored-check.sh)  
Source section: D  
Target: Fedora WSL2 distribution on Windows Server 2025  
Shell: Bash  
Privileges: Standard Linux user  
Prerequisites: Mirrored selected in Windows Server WSL Settings; start WSL and capture the reported error

```bash
wslinfo --networking-mode
ip a
```

## 12. Create the Consomme test page, inspect networking, and start its foreground HTTP server.

File: [`11-consomme-fedora.sh`](reference/11-consomme-fedora.sh)  
Source section: E  
Target: Fedora 45 WSL2 distribution on Windows Server 2025  
Shell: Bash  
Privileges: Standard Linux user; no sudo in this example  
Prerequisites: WSL already installed; Consomme selected and WSL restarted; Python 3 and writable home directory

```bash
myWebDir=~/wsl-web-demo

mkdir -p $myWebDir

cat > $myWebDir/index.html <<'EOF'
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <title>WSL2 Networking Demo</title>
</head>
<body>
    <h1>Hello, Viewers!</h1>
    <p>This page is served by Fedora 45 running in WSL2 on Windows Server 2025.</p>
    <p>An interesting change is that we are now using WSL2 Consomme networking mode.</p>
    <p><strong>Consomme networking</strong> is a WSL2 user-mode Network Address Translation (NAT) implementation that translates Linux network traffic into Windows host socket operations. It tracks listening ports in Linux and can automatically relay incoming connections through Windows host sockets to Linux services, without a manually configured port proxy, provided the application's listening settings and applicable firewall rules permit the connection. </p>
    <p>I hope you enjoyed the video and found it helpful and informative. If you have feedback, corrections, or suggestions, please share them in the comments below. Please like, subscribe, and share this video with others. Thank you for watching—I truly appreciate it! </p>
</body>
</html>
EOF

wslinfo --networking-mode
ip a
python3 -m http.server 9000 --bind 0.0.0.0 --directory $myWebDir
```

## 13. Verify the absence of manual proxies, then allow inbound TCP 9000.

File: [`12-consomme-firewall-add.ps1`](reference/12-consomme-firewall-add.ps1)  
Source section: E  
Target: Windows Server 2025 WSL host  
Shell: Windows PowerShell  
Privileges: Run as Administrator  
Prerequisites: Consomme selected and active; Fedora server from 11 is listening on TCP 9000; prior NAT proxy removed

```powershell
netsh interface portproxy show all

New-NetFirewallRule `
    -Name 'WSL-Web-TCP9000' `
    -DisplayName 'WSL Web - TCP 9000' `
    -Direction Inbound `
    -Action Allow `
    -Protocol TCP `
    -LocalAddress 192.0.2.10 `
    -LocalPort 9000 `
    -Profile Any
```

## 14. Remove the TCP 9000 demonstration firewall rule.

File: [`13-consomme-cleanup.ps1`](reference/13-consomme-cleanup.ps1)  
Source section: E  
Target: Windows Server 2025 WSL host  
Shell: Windows PowerShell  
Privileges: Run as Administrator  
Prerequisites: Finish local and external Consomme browser tests first

```powershell
Remove-NetFirewallRule -Name 'WSL-Web-TCP9000'
```

## 15. Open the current Windows user's .wslconfig with Microsoft Edit.

File: [`14-server-core-edit.ps1`](reference/14-server-core-edit.ps1)  
Source section: F  
Target: Windows Server 2025 Server Core WSL host  
Shell: Windows PowerShell  
Privileges: Current WSL owner account; elevation not needed to edit own profile  
Prerequisites: WSL installed; Microsoft Edit installed; preserve existing settings; see config/consomme.wslconfig.example

```powershell
edit $env:USERPROFILE\.wslconfig
```

## 16. Apply configuration by stopping WSL and opening the default distribution in a new window.

File: [`15-server-core-restart.ps1`](reference/15-server-core-restart.ps1)  
Source section: F  
Target: Windows Server 2025 Server Core WSL host  
Shell: Windows PowerShell  
Privileges: Current WSL owner account  
Prerequisites: Save .wslconfig first; all running WSL distributions and their applications will stop; start is a PowerShell alias

```powershell
wsl --shutdown ; start wsl
```

## 17. Display distribution information, active mode, and interface addresses.

File: [`16-server-core-fedora-checks.sh`](reference/16-server-core-fedora-checks.sh)  
Source section: F  
Target: Default Linux distribution in WSL2 on Windows Server 2025 Core  
Shell: Bash  
Privileges: sudo permission for hostnamectl, preserved from the source  
Prerequisites: WSL restarted using the edited configuration

```bash
sudo hostnamectl
wslinfo --networking-mode
ip a
```
