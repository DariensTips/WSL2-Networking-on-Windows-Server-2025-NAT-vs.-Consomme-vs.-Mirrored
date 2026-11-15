<#
Title: WSL2 Networking on Windows Server 2025: NAT vs. Consomme vs. Mirrored
Author / Channel: Darien Hawkins / Darien's Tips
Purpose: Inspect mappings, configure TCP 9409 to 8000, and display the mapping.
Source script filename: WSLWNSVRNET_Title-Chapters-Script_20261114-225958.txt
Preparation date: 2026-11-15
Tested environment: Author's video: WSL 3.0.5; Fedora 45; Windows Server 2025 and Windows 11 26H2. Server Core and Server 2022 observations are identified separately.
Target system: Windows Server 2025 WSL host
Shell: Windows PowerShell
Required privileges: Run as Administrator
Prerequisites: NAT mode; Fedora listening on TCP 8000; current guest IP; unused host port 9409; IP Helper available
Usage notes: Individual reference example, not an end-to-end automation script. Follow README order; replace documentation addresses before use. Commands were extracted from the final script, not executed on Windows here. Do not run every file on one machine.
#>

netsh interface portproxy show all

$WslIPv4 = '172.30.96.25'
netsh interface portproxy add v4tov4 `
    listenaddress=192.0.2.10 `
    listenport=9409 `
    connectaddress=$WslIPv4 `
    connectport=8000 `
    protocol=tcp

netsh interface portproxy show all
