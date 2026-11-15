<#
Title: WSL2 Networking on Windows Server 2025: NAT vs. Consomme vs. Mirrored
Author / Channel: Darien Hawkins / Darien's Tips
Purpose: Open the current Windows user's .wslconfig with Microsoft Edit.
Source script filename: WSLWNSVRNET_Title-Chapters-Script_20261114-225958.txt
Preparation date: 2026-11-15
Tested environment: Author's video: WSL 3.0.5; Fedora 45; Windows Server 2025 and Windows 11 26H2. Server Core and Server 2022 observations are identified separately.
Target system: Windows Server 2025 Server Core WSL host
Shell: Windows PowerShell
Required privileges: Current WSL owner account; elevation not needed to edit own profile
Prerequisites: WSL installed; Microsoft Edit installed; preserve existing settings; see config/consomme.wslconfig.example
Usage notes: Individual reference example, not an end-to-end automation script. Follow README order; replace documentation addresses before use. Commands were extracted from the final script, not executed on Windows here. Do not run every file on one machine.
#>

edit $env:USERPROFILE\.wslconfig
