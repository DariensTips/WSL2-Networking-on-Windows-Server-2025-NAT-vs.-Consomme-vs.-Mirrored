#!/usr/bin/env bash
# Title: WSL2 Networking on Windows Server 2025: NAT vs. Consomme vs. Mirrored
# Author / Channel: Darien Hawkins / Darien's Tips
# Purpose: Inspect the active networking mode and interfaces after the failed mirrored startup.
# Source script filename: WSLWNSVRNET_Title-Chapters-Script_20261114-225958.txt
# Preparation date: 2026-11-15
# Tested environment: Author's video: WSL 3.0.5; Fedora 45; Windows Server 2025 and Windows 11 26H2. Server Core and Server 2022 observations are identified separately.
# Target system: Fedora WSL2 distribution on Windows Server 2025
# Shell: Bash
# Required privileges: Standard Linux user
# Prerequisites: Mirrored selected in Windows Server WSL Settings; start WSL and capture the reported error
# Usage notes: Individual reference example, not an end-to-end automation script. Follow README order; replace documentation addresses before use. Commands were extracted from the final script, not executed on Windows here. Do not run every file on one machine.

wslinfo --networking-mode
ip a
