# Unified Cross-Platform IPsec Solution

A unified, policy-driven IPsec solution that enables automatic network traffic encryption across Linux, Windows, macOS, and BOSS OS using a single centralized configuration.

## Overview

Enterprise environments run multiple operating systems, each with different IPsec configuration mechanisms. This project eliminates fragmentation by providing a single policy file (policy.yaml) that is validated and deployed consistently across platforms.

## Key Features

- **Single centralized policy** for all operating systems
- **Automatic IPsec tunnel deployment** with auto-start on boot
- **Cross-platform support:** Linux (strongSwan), Windows (PowerShell), macOS, BOSS OS
- **Multiple IPsec modes:** Tunnel, Transport
- **Protocol support:** ESP, AH, ESP+AH
- **IKEv1 & IKEv2 support**
- **Multi-tunnel configuration** (multiple peers and subnets)
- **Built-in validation and logging**

## Architecture (High Level)

```
policy.yaml
     ↓
Policy Engine (validation + orchestration)
     ↓
OS Detection
     ↓
Linux | Windows | macOS | BOSS OS Adapters
```

## Core Components

- **controller/policy.yaml** – Unified IPsec policy definition
- **controller/policy_engine.py** – Policy loader, validator, and orchestrator
- **controller/validator.py** – Configuration validation
- **adapters/** – OS-specific IPsec implementations
- **installer/** – Automated installation scripts
- **services/** – Auto-start service definitions

## Supported Capabilities

| Category | Support |
|----------|---------|
| IPsec Modes | Tunnel, Transport |
| Protocols | ESP, AH, ESP+AH |
| Encryption | AES-128/192/256, 3DES |
| Integrity | SHA-1, SHA-256, SHA-384, SHA-512 |
| Key Exchange | IKEv1, IKEv2 |
| Authentication | PSK (implemented), Certificates (structure) |
| Platforms | Linux, Windows, macOS, BOSS OS |

## Quick Start

### Install
```bash
# Linux (Ubuntu/Debian/CentOS/RHEL)
cd unified-ipsec
sudo ./installer/install_linux.sh

# Windows (PowerShell as Administrator)
cd unified-ipsec
Set-ExecutionPolicy -ExecutionPolicy Bypass -Scope Process
.\installer\install_windows.ps1

# macOS
cd unified-ipsec
sudo ./installer/install_macos.sh
```

### Configure
Edit `controller/policy.yaml` with your IPsec tunnels and settings.

### Validate
```bash
python3 controller/validator.py
```

### Deploy
```bash
# Linux/macOS
sudo python3 controller/policy_engine.py

# Windows
python "C:\Program Files\UnifiedIPsec\controller\policy_engine.py"
```

### Verify
```bash
# Linux
sudo systemctl status unified-ipsec
sudo journalctl -u unified-ipsec -f

# Windows
Get-ScheduledTask -TaskName UnifiedIPsec

# macOS
sudo launchctl list | grep unifiedipsec
```

## Example Configuration

```yaml
global:
  ike_version: ikev2
  auth_method: psk
  psk: "your_pre_shared_key"
  encryption: aes256
  integrity: sha256
  dh_group: 14
  auto_start: true

tunnels:
  - name: site_to_site
    mode: tunnel
    protocol: esp
    local_subnet: 10.0.0.0/24
    remote_subnet: 192.168.1.0/24
    peer_ip: 203.0.113.10

  - name: host_to_host
    mode: transport
    protocol: esp
    peer_ip: 203.0.113.20
```

## Tunnel Verification

### Linux (with strongSwan)
```bash
# Check tunnel status
sudo ipsec status

# View detailed status
sudo ipsec statusall

# Check Security Associations
sudo ipsec listall
```

### Show Encryption Evidence (tcpdump)
```bash
# Terminal 1: Monitor ESP packets
sudo tcpdump -i any esp -n

# Terminal 2: Deploy policy
sudo python3 controller/policy_engine.py

# Terminal 3: Generate traffic
ping 192.168.1.0

# Terminal 1 will show ESP packets like:
# IP <local_ip> > <peer_ip>: ESP(spi=0x12345678,seq=0x1)
```

## Architecture Diagram

```
┌──────────────────────────────┐
│   policy.yaml (Unified)      │
│  - IPsec modes & protocols   │
│  - Encryption algorithms     │
│  - Authentication methods    │
└────────────┬─────────────────┘
             │
             ↓
┌──────────────────────────────┐
│   policy_engine.py           │
│  - Loads & validates policy  │
│  - Detects OS                │
│  - Calls adapter             │
│  - Logs tunnel status        │
└────────────┬─────────────────┘
             │
    ┌────────┼────────┬──────────┐
    ↓        ↓        ↓          ↓
  Linux   Windows  macOS      BOSS OS
strongSwan PowerShell setkey  IKE Module
```

## File Structure

```
controller/
├── policy.yaml              # Unified policy definition
├── policy_engine.py         # Main orchestrator
└── validator.py             # Configuration validator

adapters/
├── linux/strongswan_adapter.py
├── windows/windows_ipsec.ps1
├── macos/macos_ipsec.sh
└── boss_os/boss_adapter.py

installer/
├── install_linux.sh
├── install_windows.ps1
└── install_macos.sh

services/
└── unified-ipsec.service    # systemd auto-start

logs/                         # Runtime logs
```

## Status & Notes

- **Hackathon prototype** (not production-ready)
- **Primary focus:** Linux (strongSwan)
- **Windows support:** Implemented via PowerShell
- **macOS adapter:** Currently a stub demonstrating concepts
- **Certificate-based authentication:** Structure ready, adapters need extension

## Testing

### Demo (Non-Destructive)
```bash
./demo.sh
```

### Test Encrypted Traffic (Linux)
```bash
# Terminal 1: Monitor ESP packets
sudo tcpdump -i any esp

# Terminal 2: Configure and deploy
sudo python3 controller/policy_engine.py

# Terminal 3: Generate traffic
ping <remote_subnet_ip>

# Terminal 1 should show ESP packets indicating encryption
```

## Troubleshooting

### Linux
```bash
# Check strongSwan status
sudo ipsec status

# Verify configuration
sudo ipsec verify

# View logs
sudo journalctl -u unified-ipsec -f
```

### Windows
```powershell
# Check scheduled task
Get-ScheduledTask -TaskName UnifiedIPsec

# View IPsec rules
Get-NetIPsecRule

# Check IPsec SAs
Get-NetIPsecMainModeSA
```

### macOS
```bash
# Check daemon status
sudo launchctl list | grep unifiedipsec

# View logs
tail -f /usr/local/unified-ipsec/logs/ipsec.log
```

## License

MIT License

---

**Built with ❤️ for network administrators everywhere!**
