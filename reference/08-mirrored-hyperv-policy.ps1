<#
Title: WSL2 Networking on Windows Server 2025: NAT vs. Consomme vs. Mirrored
Author / Channel: Darien Hawkins / Darien's Tips
Purpose: Inspect effective WSL Hyper-V firewall settings after the browser tests.
Source script filename: WSLWNSVRNET_Title-Chapters-Script_20261114-225958.txt
Preparation date: 2026-11-15
Tested environment: Author's video: WSL 3.0.5; Fedora 45; Windows Server 2025 and Windows 11 26H2. Server Core and Server 2022 observations are identified separately.
Target system: Windows 11 26H2 WSL host
Shell: Windows PowerShell
Required privileges: Administrative session, as used in the demonstration
Prerequisites: WSL Hyper-V firewall cmdlets available; do not substitute a machine-specific VM ID for the supplied WSL creator ID
Usage notes: Individual reference example, not an end-to-end automation script. Follow README order; replace documentation addresses before use. Commands were extracted from the final script, not executed on Windows here. Do not run every file on one machine.
#>

Get-NetFirewallHyperVVMSetting `
    -PolicyStore ActiveStore `
    -Name '{40E0AC32-46A5-438A-A0B2-2B479E8F2E90}' |
    Select-Object Enabled, AllowHostPolicyMerge, DefaultInboundAction
