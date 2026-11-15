# WSL2 Networking on Windows Server 2025: NAT vs. Consomme vs. Mirrored

## Watch the video

**Video link: https://www.youtube.com/watch?v=OiqRTiFeGB4**

Video title: **WSL2 Networking on Windows Server 2025: NAT vs. Consomme vs. Mirrored**

Channel: https://www.youtube.com/@darienstips9409  
Repository supplied by the author: https://github.com/DariensTips/WSL2-Networking-on-Windows-Server-2025-NAT-vs.-Consomme-vs.-Mirrored

<img width="1920" height="1080" alt="wsl2-networking-on-windows-server-2025-nat-vs-consomme-vs-mirrored-withpic" src="https://github.com/user-attachments/assets/d9a94de3-cd8e-4651-9088-67b36c2c8217" />


**Author / channel:** Darien Hawkins / Darien's Tips  
**Purpose:** Companion reference examples for comparing WSL2 NAT, Mirrored, and Consomme networking and testing inbound HTTP connectivity.  
**Source script:** `WSLWNSVRNET_Title-Chapters-Script_20261114-225958.txt`  
**Preparation date:** 2026-11-15  
**Tested environment stated in the video:** WSL 3.0.5; Fedora 45; Windows Server 2025 Desktop Experience; Windows 11 26H2. The video also covers Windows Server 2025 Core and reports a Windows Server 2022 fallback observation. Exact Windows builds and Python patch versions are not specified in the final script.  
**Usage notes:** Use individual examples on the identified systems, in the video order. This is not an installer, service deployment, or all-in-one script. Read the prerequisites and replace the documentation values before running commands.


## Overview

The video establishes NAT behavior first, adds a manual TCP proxy, compares mirrored mode on Windows 11 with the Windows Server restriction, and then demonstrates Consomme as another way to reach a Linux service from the LAN. Similar application-connectivity results do not make the implementations identical.

| Demonstration | Windows host | Client-facing endpoint | Linux listener |
|---|---|---|---|
| NAT baseline | Server 2025 | Linux NAT address:8000 or host localhost:8000 | TCP 8000 |
| NAT plus manual proxy | Server 2025 | Host LAN address:9409 | Linux NAT address:8000 |
| Mirrored | Windows 11 26H2 | Windows host name/address:7000 | TCP 7000 |
| Consomme | Server 2025 | Windows host name/address:9000 | TCP 9000 |

The application is an IPv4 HTTP test page. TLS, UDP connectivity, VPN behavior, performance, IPv6 application access, unattended startup, and production availability are not established by these demonstrations.

## Chapters

```text
00:00 Introduction
01:09 WSL2 Networking: NAT Mode
03:36 TCP Port Forwarding via NETSH
05:39 WSL2 Networking: Mirrored Mode
08:33 WSL2 Networking: Consomme Mode
10:09 WSL2 on Windows Server 2025 Core
11:17 WSL2 Networking: Key Takeaways
11:51 Thank you for watching
```

## Prerequisites

- WSL2 and the demonstrated Linux distribution are already installed; this video is a networking comparison, not an installation walkthrough. WSL installation requirements are in the official links below.
- Python 3, Bash, `ip`, and `wslinfo` are available inside the distribution. A writable home directory is required for `~/wsl-web-demo`.
- Use the Windows account that owns the relevant WSL distributions. Use an elevated Windows PowerShell session for proxy and firewall modifications. Linux HTTP listeners on the demonstrated high ports run as a normal user.
- Provide a second Windows client and a Linux client with network reachability; the Linux client in the video is not domain-joined. Hostname-based URLs require DNS or another valid name-resolution mechanism.
- Keep the Linux HTTP server running while performing Windows/browser tests. Any Linux firewall must permit the intended application traffic. The selected ports must not already be in use.
- For the NAT proxy, the Windows IP Helper service and applicable host networking components must be available. The source does not change those services, so these reference files do not introduce service configuration commands.
- Microsoft Edit must be installed for the exact Server Core editor command shown. The video also mentions Notepad as an alternative; use an available editor without replacing unrelated configuration.

## Placeholder and example-value guide

The command logic is preserved. Only the following environment-specific values are generalized. **Do not assign these documentation LAN addresses to production interfaces or expect them to work unchanged.** Replace them everywhere with your own values.

| Example value | Replace with |
|---|---|
| `192.0.2.10` | Actual Windows Server WSL host LAN IPv4 address |
| `192.0.2.20` | Actual Windows 11 WSL host LAN IPv4 address |
| `172.30.96.25` | Current Fedora NAT IPv4 address shown by `ip a`, not the Windows vEthernet address |
| `server2025.example.test` | A name resolving to your Windows Server LAN address |
| `win11.example.test` | A name resolving to your Windows 11 LAN address |
| `~/wsl-web-demo` | The user's demonstration content directory; retained from the script |
| `VIDEO_URL` | Published video URL; not supplied at package preparation |

The loopback address `127.0.0.1`, wildcard bind address `0.0.0.0`, WSL creator GUID, port numbers, firewall-rule names, and command options are not placeholders and are retained from the video. `start` in the Server Core command is the PowerShell alias for `Start-Process`.

## How to use the files

[COMMAND_REFERENCE.md](COMMAND_REFERENCE.md) contains copyable, separate examples with target system, shell, privileges, prerequisites, and source section. The `reference/` folder provides those same examples as PowerShell and Bash files. No new automation, automatic address discovery, scheduled task, or persistent web service has been added. Do not run setup and cleanup together or execute all files on one host.

### B. NAT baseline — Windows Server 2025

In WSL Settings, select **Networking > NAT**, apply changes as necessary, and restart WSL before checking the active mode. In Fedora, use `01-nat-fedora.sh`. It creates the source HTML, displays `wslinfo --networking-mode` and `ip a`, and starts Python on TCP 8000. This command stays in the foreground.

On Windows, use the `ipconfig` example in `02-nat-windows-checks.ps1`. Perform the browser checks before the TCP comparison in that file:

```text
http://172.30.96.25:8000/
http://localhost:8000/
http://192.0.2.10:8000/
```

In the recorded baseline, the first two work and access through the host LAN address fails. The Python page verifies an HTTP response; `Test-NetConnection` separately tests TCP connection establishment. Actual failure wording depends on the environment.

### C. Manual TCP forwarding — same Windows Server host

With Fedora still listening, run `03-nat-portproxy-add.ps1` in elevated Windows PowerShell. It shows existing mappings, sets `$WslIPv4`, maps host TCP 9409 to guest TCP 8000 using `v4tov4`, and shows the new mapping. Next, run `04-nat-firewall-add.ps1` to allow the host's incoming port 9409.

Open locally, then from the external Windows and Linux clients:

```text
http://192.0.2.10:9409/
http://server2025.example.test:9409/
```

After the successful browser tests, run `05-nat-cleanup.ps1`. It deletes only the specified mapping, removes its named firewall rule, and displays any remaining proxies. `portproxy` supports TCP, not UDP. Its listen address must match when deleting the mapping. Recheck the guest address if NAT is restarted or reconfigured.

### D. Mirrored — Windows 11 first

On the separate Windows 11 host, select **Mirrored**, keep **Hyper-V Firewall enabled**, apply changes, and shut down WSL. Run `06a-mirrored-windows-adapters.ps1` before launching Fedora. Then use `06-mirrored-fedora.sh` inside Fedora to show the active mode and interfaces and start Python on TCP 7000.

Create the demonstrated Windows rule with `07-mirrored-firewall-add.ps1` in an administrative session. Test locally and from the external clients:

```text
http://localhost:7000/
http://win11.example.test:7000/
```

The author observed matching host/guest adapter addressing and successful inbound requests. The port-scoped host rule was sufficient in that environment; this does not mean Hyper-V firewall is bypassed. Use `08-mirrored-hyperv-policy.ps1` to display `Enabled`, `AllowHostPolicyMerge`, and `DefaultInboundAction` in the effective `ActiveStore`, as shown in the video. Other environments may require explicit Hyper-V firewall configuration; this package does not silently add it. Finally, use `09-mirrored-cleanup.ps1`.

Switch back to Windows Server 2025. Select Mirrored with Hyper-V Firewall enabled, apply changes, shut down WSL, and launch it. Run `10-server-mirrored-check.sh` in the distribution. The video reports error `0x803b0015`, fallback to `None`, and only loopback networking. A separate Server 2022 test reportedly fell back to NAT; that is an observed result, not a universal fallback guarantee.

### E. Consomme — Windows Server 2025

In WSL Settings, select **Consomme**, apply the change, shut down WSL, and launch it. Run `11-consomme-fedora.sh` inside Fedora to create the page, confirm the mode, inspect interfaces, and listen on TCP 9000. The script's page text is retained, including its closing thank-you paragraph.

In elevated Windows PowerShell, `12-consomme-firewall-add.ps1` first displays port-proxy mappings, then creates the demonstrated TCP 9000 rule. Confirm that a manual proxy is not responsible for the test. Test from the host and the external Windows/Linux clients:

```text
http://localhost:9000/
http://server2025.example.test:9000/
```

The recorded result is inbound HTTP connectivity with Windows Firewall enabled and no manually configured `netsh portproxy`. Consomme uses a user-mode backend and Windows host sockets; it is not mirrored mode under another name. The final script also states that Consomme works on Windows 11, without documenting a separate, complete Windows 11 Consomme test sequence. Remove the named rule with `13-consomme-cleanup.ps1` after testing.

### F. Server Core — manual configuration

The video demonstrates editing `.wslconfig` because the WSL Settings GUI did not launch on the tested Server Core system. This is a reported observation, not a prediction for every future GUI release.

Use `14-server-core-edit.ps1`, then edit the existing `[wsl2]` section as described in [config/consomme.wslconfig.example](config/consomme.wslconfig.example). Preserve unrelated values. The example file is documentation, not an automatically deployed replacement.

```ini
[wsl2]
networkingMode=consomme
```

After saving, `15-server-core-restart.ps1` preserves the exact demonstrated sequence:

```powershell
wsl --shutdown ; start wsl
```

This stops all running WSL distributions and the WSL2 VM, then opens the default distribution in a new window. It does not restart the Python service automatically. Inside the new Linux session, use `16-server-core-fedora-checks.sh`: `sudo hostnamectl`, `wslinfo --networking-mode`, and `ip a`. `.wslconfig` applies to the current Windows user's WSL2 distributions, not WSL1 or other Windows accounts.

## Command explanations and operational boundaries

`wslinfo --networking-mode` reports the active mode rather than merely the requested setting. `ip a` shows Linux interfaces; `ipconfig` and `ipconfig /all` show Windows adapters. The Windows NAT-side vEthernet address is not the Linux guest address.

The Python `--bind 0.0.0.0` option listens on all IPv4 interfaces inside the distribution. `--directory` selects the content root. The source's unquoted `$myWebDir` expansions are preserved; keep that demonstration path free of spaces rather than treating these files as a refactored Bash framework. Each page-creation example overwrites `index.html` in the demonstration directory.

The firewall examples deliberately retain `-Profile Any` and the source's lack of `-RemoteAddress`. Thus, they are destination-address/port scoped, not source-subnet restricted. Apply your organization's access policy; a narrower source scope may be appropriate, but it has not been silently added to the demonstrated commands. Rules persist until removed; calling them temporary does not make them expire.

Python's simple HTTP server is for this lab only, not a production server. Do not serve secrets or expose it to untrusted networks. Stop foreground servers with Ctrl+C and perform the supplied cleanup when finished. Configuration changes and WSL shutdown can interrupt other workloads.

## Testing and provenance

The connectivity outcomes above are the author's tests recorded in the final source script, not new tests performed by the package preparer. The script reports local and external browser verification, NAT TCP endpoint checks, Windows/Hyper-V firewall inspection, manual proxy cleanup, mirrored startup failure on Server, and Server Core mode/interface inspection. No claim of equivalent VPN, UDP, multicast, IPv6, performance, or production behavior is made.

During package preparation, code text was compared with the supplied final revision and the Bash files received syntax-only checks. Windows firewall/proxy commands and the complete cross-machine demonstrations were not executed in this preparation environment. All generated examples retain their original sequence within each procedure, with setup, client verification, and cleanup explicitly separated.

## Official references

- [WSL networking: NAT, localhost, LAN access, and mirrored mode](https://learn.microsoft.com/en-us/windows/wsl/networking)
- [WSL advanced configuration, networkingMode, and .wslconfig scope](https://learn.microsoft.com/en-us/windows/wsl/wsl-config)
- [WSL installation on Windows Server 2022/2025, including Server Core](https://learn.microsoft.com/en-us/windows/wsl/install-on-server)
- [netsh interface portproxy reference](https://learn.microsoft.com/en-us/windows-server/administration/windows-commands/netsh-interface)
- [Hyper-V firewall and effective policy](https://learn.microsoft.com/en-us/windows/security/operating-system-security/network-security/windows-firewall/hyper-v-firewall)
- [WSL localhost internals: NAT, Mirrored, and Consomme](https://wsl.dev/technical-documentation/localhost/)
- [Microsoft WSL repository: contributor confirmation of Server mirrored restriction](https://github.com/microsoft/WSL/issues/40439)
- [Python HTTP server options and production warning](https://docs.python.org/3/library/http.server.html)
- [WSL basic commands and shutdown behavior](https://learn.microsoft.com/en-us/windows/wsl/basic-commands)
- [New-NetFirewallRule](https://learn.microsoft.com/en-us/powershell/module/netsecurity/new-netfirewallrule?view=windowsserver2025-ps)
- [Remove-NetFirewallRule](https://learn.microsoft.com/en-us/powershell/module/netsecurity/remove-netfirewallrule?view=windowsserver2025-ps)
- [Get-NetFirewallHyperVVMSetting](https://learn.microsoft.com/en-us/powershell/module/netsecurity/get-netfirewallhypervvmsetting?view=windowsserver2025-ps)
- [Test-NetConnection](https://learn.microsoft.com/en-us/powershell/module/nettcpip/test-netconnection?view=windowsserver2025-ps)
- [Microsoft Edit](https://learn.microsoft.com/en-us/windows/edit/)
- [Microsoft Hyper-V MAC address prefix](https://learn.microsoft.com/en-us/troubleshoot/windows-server/virtualization/default-limit-256-dynamic-mac-addresses)
- [Windows Server 2022 WSL2 announcement and build 20348.740](https://techcommunity.microsoft.com/blog/itopstalkblog/wsl2-now-available-on-windows-server-2022/3447570)
- [NAT terminology, RFC 2663](https://www.rfc-editor.org/rfc/rfc2663.html)

## Attribution

Tutorial and demonstrated workflow: Darien Hawkins / Darien's Tips. Microsoft, Windows, WSL, Fedora, and Python names and marks belong to their respective owners. This is an independent educational reference, not a Microsoft or Fedora endorsement.
