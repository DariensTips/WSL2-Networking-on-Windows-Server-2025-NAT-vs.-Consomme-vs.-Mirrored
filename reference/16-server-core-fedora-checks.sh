#!/usr/bin/env bash
# Title: WSL2 Networking on Windows Server 2025: NAT vs. Consomme vs. Mirrored
# Author / Channel: Darien Hawkins / Darien's Tips
# Purpose: Display distribution information, active mode, and interface addresses.
# Source script filename: WSLWNSVRNET_Title-Chapters-Script_20261114-225958.txt
# Preparation date: 2026-11-15
# Tested environment: Author's video: WSL 3.0.5; Fedora 45; Windows Server 2025 and Windows 11 26H2. Server Core and Server 2022 observations are identified separately.
# Target system: Default Linux distribution in WSL2 on Windows Server 2025 Core
# Shell: Bash
# Required privileges: sudo permission for hostnamectl, preserved from the source
# Prerequisites: WSL restarted using the edited configuration
# Usage notes: Individual reference example, not an end-to-end automation script. Follow README order; replace documentation addresses before use. Commands were extracted from the final script, not executed on Windows here. Do not run every file on one machine.

sudo hostnamectl
wslinfo --networking-mode
ip a
