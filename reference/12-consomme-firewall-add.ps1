<#
Title: WSL2 Networking on Windows Server 2025: NAT vs. Consomme vs. Mirrored
Author / Channel: Darien Hawkins / Darien's Tips
Purpose: Verify the absence of manual proxies, then allow inbound TCP 9000.
Source script filename: WSLWNSVRNET_Title-Chapters-Script_20261114-225958.txt
Preparation date: 2026-11-15
Tested environment: Author's video: WSL 3.0.5; Fedora 45; Windows Server 2025 and Windows 11 26H2. Server Core and Server 2022 observations are identified separately.
Target system: Windows Server 2025 WSL host
Shell: Windows PowerShell
Required privileges: Run as Administrator
Prerequisites: Consomme selected and active; Fedora server from 11 is listening on TCP 9000; prior NAT proxy removed
Usage notes: Individual reference example, not an end-to-end automation script. Follow README order; replace documentation addresses before use. Commands were extracted from the final script, not executed on Windows here. Do not run every file on one machine.
#>

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
