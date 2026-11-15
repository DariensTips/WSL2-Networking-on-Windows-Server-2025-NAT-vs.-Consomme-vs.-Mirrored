<#
Title: WSL2 Networking on Windows Server 2025: NAT vs. Consomme vs. Mirrored
Author / Channel: Darien Hawkins / Darien's Tips
Purpose: Inspect the Windows adapters and compare the three TCP endpoints.
Source script filename: WSLWNSVRNET_Title-Chapters-Script_20261114-225958.txt
Preparation date: 2026-11-15
Tested environment: Author's video: WSL 3.0.5; Fedora 45; Windows Server 2025 and Windows 11 26H2. Server Core and Server 2022 observations are identified separately.
Target system: Windows Server 2025 WSL host
Shell: Windows PowerShell
Required privileges: Standard user
Prerequisites: NAT Fedora HTTP server from 01 is running on TCP 8000; replace both IP examples
Usage notes: Individual reference example, not an end-to-end automation script. Follow README order; replace documentation addresses before use. Commands were extracted from the final script, not executed on Windows here. Do not run every file on one machine.
#>

ipconfig

# Browser checks between these two command examples are listed in README.md.
$LocalIPs="172.30.96.25","127.0.0.1","192.0.2.10"
$LocalIPs | ForEach-Object {Test-NetConnection -ComputerName $_ -Port 8000}
