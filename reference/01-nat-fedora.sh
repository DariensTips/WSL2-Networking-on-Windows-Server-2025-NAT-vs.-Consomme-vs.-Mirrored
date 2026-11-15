#!/usr/bin/env bash
# Title: WSL2 Networking on Windows Server 2025: NAT vs. Consomme vs. Mirrored
# Author / Channel: Darien Hawkins / Darien's Tips
# Purpose: Create the NAT test page, inspect networking, and start its foreground HTTP server.
# Source script filename: WSLWNSVRNET_Title-Chapters-Script_20261114-225958.txt
# Preparation date: 2026-11-15
# Tested environment: Author's video: WSL 3.0.5; Fedora 45; Windows Server 2025 and Windows 11 26H2. Server Core and Server 2022 observations are identified separately.
# Target system: Fedora 45 WSL2 distribution on Windows Server 2025
# Shell: Bash
# Required privileges: Standard Linux user; no sudo in this example
# Prerequisites: WSL already installed; NAT selected and WSL restarted; Python 3 and writable home directory
# Usage notes: Individual reference example, not an end-to-end automation script. Follow README order; replace documentation addresses before use. Commands were extracted from the final script, not executed on Windows here. Do not run every file on one machine.

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
