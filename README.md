# Unified Cross-Platform IPsec Solution# Unified Cross-Platform IPsec Solution



[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)

![Python 3.6+](https://img.shields.io/badge/python-3.6+-blue.svg)![Python 3.6+](https://img.shields.io/badge/python-3.6+-blue.svg)



A unified IPsec solution for enterprises to automatically encrypt network traffic across Windows, Linux (Ubuntu/Debian/RHEL/BOSS), and macOS using centrally defined policies.



## Problem StatementA unified IPsec solution for enterprises to automatically encrypt network traffic across Windows, Linux (Ubuntu/Debian/RHEL/BOSS), and macOS using centrally defined policies.A unified IPsec solution for enterprises to automatically encrypt network traffic across Windows, Linux (Ubuntu/Debian/RHEL/BOSS), and macOS using centrally defined policies.



Enterprise networks consist of diverse operating systems (Windows, Linux, macOS, BOSS) requiring consistent encryption policies. Currently:

- **Linux** uses strongSwan with `ipsec.conf`

- **Windows** uses PowerShell cmdlets and IPsec rules## Problem Statement## Problem Statement

- **macOS** uses racoon or IKEv2 profiles

- **BOSS OS** requires custom kernel module integration



This fragmentation leads to:Enterprise networks consist of diverse operating systems (Windows, Linux, macOS, BOSS) requiring consistent encryption policies. Currently:Enterprise networks consist of diverse operating systems (Windows, Linux, macOS, BOSS) requiring consistent encryption policies. Currently:

- Configuration inconsistencies and security gaps

- Deployment delays and operational complexity- **Linux** uses strongSwan with `ipsec.conf`- **Linux** uses strongSwan with `ipsec.conf`

- Manual configuration on each device

- Lack of centralized policy management- **Windows** uses PowerShell cmdlets and IPsec rules- **Windows** uses PowerShell cmdlets and IPsec rules



## Solution- **macOS** uses racoon or IKEv2 profiles- **macOS** uses racoon or IKEv2 profiles



**Unified IPsec** provides:- **BOSS OS** requires custom kernel module integration- **BOSS OS** requires custom kernel module integration

1. **Single policy file** (`policy.yaml`) deployed to all operating systems

2. **Automatic encryption** of traffic based on centrally defined policies

3. **Zero-touch deployment** with auto-start on boot

4. **Complete IPsec mode support** (ESP Tunnel, ESP Transport, AH Tunnel, AH Transport, ESP+AH)This fragmentation leads to configuration inconsistencies, security gaps, deployment delays, and operational complexity.This fragmentation leads to:

5. **Multi-tunnel capability** for different peers and subnets

6. **Comprehensive logging** for tunnel status and troubleshooting- Configuration inconsistencies and security gaps



## Architecture## Solution- Deployment delays and operational complexity



```- Manual configuration on each device

Policy Definition (policy.yaml)

          ↓**Unified IPsec** provides:- Lack of centralized policy management

Policy Engine (policy_engine.py)

          ↓1. **Single policy file** (`policy.yaml`) deployed across all operating systems

    Platform Detection

          ↓2. **Automatic encryption** of traffic based on centrally defined policies## Solution

    ┌─────┬─────┬──────┐

    ▼     ▼     ▼      ▼3. **Zero-touch deployment** with auto-start on boot

  Linux Windows macOS BOSS OS

```4. **Complete IPsec mode support** (ESP Tunnel, ESP Transport, AH Tunnel, AH Transport, ESP+AH)**Unified IPsec** provides:



### Components5. **Multi-tunnel capability** for different peers and subnets1. **Single policy file** (`policy.yaml`) deployed to all operating systems



- **controller/policy.yaml** - Unified policy definition6. **Comprehensive logging** for tunnel status and troubleshooting2. **Automatic encryption** of traffic based on centrally defined policies

- **controller/policy_engine.py** - Main orchestrator and validator

- **controller/validator.py** - Configuration validation3. **Zero-touch deployment** with auto-start on boot

- **adapters/** - OS-specific implementations

  - `linux/strongswan_adapter.py` - strongSwan configuration## Architecture4. **Complete IPsec mode support** (ESP Tunnel, ESP Transport, AH Tunnel, AH Transport, ESP+AH)

  - `windows/windows_ipsec.ps1` - Windows IPsec deployment

  - `macos/macos_ipsec.sh` - macOS IKEv2 configuration5. **Multi-tunnel capability** for different peers and subnets

  - `boss_os/boss_adapter.py` - BOSS OS kernel integration

- **installer/** - Deployment scripts for each OS```

- **services/unified-ipsec.service** - Linux systemd auto-start

Policy Definition (policy.yaml)## Architecture

## Key Features

          ↓

✅ **All IPsec Modes Supported**

- Tunnel mode (site-to-site)Policy Engine (policy_engine.py)```

- Transport mode (host-to-host)

- AH (authentication-only)          ↓┌──────────────────────────────┐

- ESP+AH (combined encryption and authentication)

    Platform Detection│   policy.yaml (Unified)      │

✅ **Flexible Configuration**

- IKEv1 and IKEv2 support          ↓│  - IPsec modes & protocols   │

- Multiple encryption algorithms (AES-128, AES-192, AES-256, 3DES)

- Multiple integrity algorithms (SHA-1, SHA-256, SHA-384, SHA-512, MD5)    ┌─────┬─────┬──────┐│  - Encryption algorithms     │

- PSK and certificate-based authentication (PSK fully implemented)

- Configurable DH groups (2, 5, 14, 15, 16, 17, 18, 19, 20, 21)    ▼     ▼     ▼      ▼│  - Authentication methods    │



✅ **Automatic Operation**  Linux Windows macOS BOSS OS└────────────┬─────────────────┘

- Auto-start on system boot

- Automatic tunnel initialization and recovery```             │

- Comprehensive logging of tunnel status and events

- Configuration validation before deployment             ▼



✅ **Cross-Platform****Components:**┌──────────────────────────────┐

- Single policy for all operating systems

- Platform-specific adapters handle OS differences- **controller/policy.yaml** - Unified IPsec policy definition│  policy_engine.py            │

- Uniform security parameters across network

- **controller/policy_engine.py** - Orchestrator and validator│  - Loads & validates policy  │

## Installation

- **adapters/** - OS-specific implementations│  - Detects OS                │

### Linux (Ubuntu/Debian/CentOS/RHEL/BOSS)

```bash- **installer/** - Automated deployment scripts│  - Calls adapter             │

cd unified-ipsec

sudo ./installer/install_linux.sh- **services/** - Auto-start configurations│  - Logs tunnel status        │

```

└────────────┬─────────────────┘

### Windows (PowerShell as Administrator)

```powershell## Key Features             │

cd unified-ipsec

Set-ExecutionPolicy -ExecutionPolicy Bypass -Scope Process    ┌────────┼────────┬──────────┐

.\installer\install_windows.ps1

```✅ **All IPsec Modes Supported**    ▼        ▼        ▼          ▼



### macOS- Tunnel mode (site-to-site)  Linux   Windows  macOS      BOSS OS

```bash

cd unified-ipsec- Transport mode (host-to-host)strongSwan PowerShell setkey  IKE Module

sudo ./installer/install_macos.sh

```- AH (authentication-only)```



## Configuration- ESP+AH (combined encryption and authentication)



Edit `controller/policy.yaml` to define your IPsec policies:### Components



```yaml✅ **Flexible Configuration**

global:

  ike_version: ikev2           # IKE protocol version- IKEv1 and IKEv2 support- **controller/policy.yaml** - Unified policy definition

  auth_method: psk             # Authentication method

  psk: "shared_secret_key"     # Pre-shared key- Multiple encryption algorithms (AES-128, AES-192, AES-256, 3DES)- **controller/policy_engine.py** - Main orchestrator

  encryption: aes256           # Encryption algorithm

  integrity: sha256            # Integrity algorithm- Multiple integrity algorithms (SHA-1, SHA-256, SHA-384, SHA-512, MD5)- **controller/validator.py** - Configuration validation

  dh_group: 14                 # Diffie-Hellman group

  auto_start: true             # Auto-start on boot- PSK and certificate-based authentication (PSK fully implemented)- **adapters/** - OS-specific implementations



tunnels:- Configurable DH groups- **installer/** - Deployment scripts

  # Site-to-site tunnel (ESP Tunnel Mode)

  - name: site_to_site- **services/unified-ipsec.service** - Linux auto-start

    mode: tunnel

    protocol: esp✅ **Automatic Operation**

    local_subnet: 10.0.0.0/24

    remote_subnet: 192.168.1.0/24- Auto-start on system boot## Installation

    peer_ip: 203.0.113.10

- Automatic tunnel initialization and recovery

  # Host-to-host (ESP Transport Mode)

  - name: host_to_host- Comprehensive logging of tunnel status and events### Linux (Ubuntu/Debian/CentOS/RHEL)

    mode: transport

    protocol: esp- Configuration validation before deployment```bash

    peer_ip: 203.0.113.20

cd unified-ipsec

  # AH Tunnel Mode (authentication-only)

  - name: auth_tunnel✅ **Cross-Platform**sudo ./installer/install_linux.sh

    mode: tunnel

    protocol: ah- Single policy for all operating systems```

    local_subnet: 10.1.0.0/24

    remote_subnet: 192.168.2.0/24- Platform-specific adapters handle OS differences

    peer_ip: 203.0.113.30

- Uniform security parameters across network### Windows (PowerShell as Administrator)

  # ESP + AH Combined

  - name: combined_tunnel```powershell

    mode: tunnel

    protocol: esp-ah## Installationcd unified-ipsec

    local_subnet: 10.2.0.0/24

    remote_subnet: 192.168.3.0/24Set-ExecutionPolicy -ExecutionPolicy Bypass -Scope Process

    peer_ip: 203.0.113.40

```### Linux (Ubuntu/Debian/CentOS/RHEL/BOSS).\installer\install_windows.ps1



## Usage```bash```



### Validate Configurationcd unified-ipsec

```bash

python3 controller/validator.pysudo ./installer/install_linux.sh### macOS

```

``````bash

### Deploy Policy

```bashcd unified-ipsec

# Linux/macOS

sudo python3 controller/policy_engine.py### Windows (PowerShell as Administrator)sudo ./installer/install_macos.sh



# Windows```powershell```

python "C:\Program Files\UnifiedIPsec\controller\policy_engine.py"

```cd unified-ipsec



### View Status and LogsSet-ExecutionPolicy -ExecutionPolicy Bypass -Scope Process## Configuration

```bash

# Linux - Service status.\installer\install_windows.ps1

sudo systemctl status unified-ipsec

sudo journalctl -u unified-ipsec -f```Edit `controller/policy.yaml`:



# Linux/macOS - Application logs

tail -f logs/ipsec.log

### macOS```yaml

# Windows - Task status

Get-ScheduledTask -TaskName UnifiedIPsec```bashglobal:



# macOS - Daemon statuscd unified-ipsec  ike_version: ikev2

sudo launchctl list | grep unifiedipsec

```sudo ./installer/install_macos.sh  auth_method: psk



## Testing```  psk: "shared_secret_key"



### Demo (Non-Destructive)  encryption: aes256

```bash

./demo.sh## Configuration  integrity: sha256

```

  dh_group: 14

### Test Encrypted Traffic (Linux)

```bashEdit `controller/policy.yaml` to define your IPsec policies:  auto_start: true

# Terminal 1: Monitor ESP packets

sudo tcpdump -i any esp



# Terminal 2: Configure and deploy```yamltunnels:

sudo python3 controller/policy_engine.py

global:  # Site-to-site tunnel (ESP Tunnel Mode)

# Terminal 3: Generate traffic through tunnel

ping <remote_subnet_ip>  ike_version: ikev2           # IKE protocol version  - name: site_to_site



# Terminal 1 should show ESP packets indicating encryption  auth_method: psk             # Authentication method    mode: tunnel

```

  psk: "shared_secret_key"     # Pre-shared key    protocol: esp

## Supported Configurations

  encryption: aes256           # Encryption algorithm    local_subnet: 10.0.0.0/24

| Category | Supported |

|----------|-----------|  integrity: sha256            # Integrity algorithm    remote_subnet: 192.168.1.0/24

| **IPsec Modes** | Tunnel, Transport |

| **Protocols** | ESP, AH, ESP+AH |  dh_group: 14                 # Diffie-Hellman group    peer_ip: 203.0.113.10

| **Encryption** | AES-128, AES-192, AES-256, 3DES |

| **Integrity** | SHA-1, SHA-256, SHA-384, SHA-512, MD5 |  auto_start: true             # Auto-start on boot

| **Key Exchange** | IKEv1, IKEv2 |

| **DH Groups** | 2, 5, 14, 15, 16, 17, 18, 19, 20, 21 |  # Host-to-host (ESP Transport Mode)

| **Authentication** | PSK (fully), Certificates (structure) |

| **Platforms** | Linux, Windows, macOS, BOSS OS |tunnels:  - name: host_to_host



## File Structure  # Site-to-site tunnel (ESP Tunnel Mode)    mode: transport



```  - name: site_to_site    protocol: esp

controller/

├── policy.yaml              # Unified policy definition    mode: tunnel    peer_ip: 203.0.113.20

├── policy_engine.py         # Main orchestrator

└── validator.py             # Configuration validator    protocol: esp



adapters/    local_subnet: 10.0.0.0/24  # AH Tunnel Mode (authentication-only)

├── linux/strongswan_adapter.py

├── windows/windows_ipsec.ps1    remote_subnet: 192.168.1.0/24  - name: auth_tunnel

├── macos/macos_ipsec.sh

└── boss_os/boss_adapter.py    peer_ip: 203.0.113.10    mode: tunnel



installer/    protocol: ah

├── install_linux.sh

├── install_windows.ps1  # Host-to-host (ESP Transport Mode)    local_subnet: 10.1.0.0/24

└── install_macos.sh

  - name: host_to_host    remote_subnet: 192.168.2.0/24

services/

└── unified-ipsec.service    # systemd auto-start    mode: transport    peer_ip: 203.0.113.30



demo.sh                       # Non-destructive demo    protocol: esp

logs/                         # Runtime logs

```    peer_ip: 203.0.113.20  # ESP + AH Combined (encryption + dual authentication)



## License  - name: combined_tunnel



MIT License - see LICENSE file for details  # AH Tunnel Mode (authentication-only)    mode: tunnel



## Contributing  - name: auth_tunnel    protocol: esp-ah



Contributions welcome! Focus areas:    mode: tunnel    local_subnet: 10.2.0.0/24

- macOS adapter completion

- Certificate-based authentication    protocol: ah    remote_subnet: 192.168.3.0/24

- Windows advanced IPsec configurations

- Performance optimization    local_subnet: 10.1.0.0/24    peer_ip: 203.0.113.40

- Additional OS support

    remote_subnet: 192.168.2.0/24```

## Quick Start

    peer_ip: 203.0.113.30

1. **Install**: Run installer for your OS

2. **Configure**: Edit `policy.yaml`## Usage

3. **Validate**: Run `python3 controller/validator.py`

4. **Deploy**: Run `python3 controller/policy_engine.py`  # ESP + AH Combined

5. **Verify**: Check logs and tunnel status

  - name: combined_tunnel### Validate Configuration

For detailed information, see QUICKSTART.md and TECHNICAL_DOCUMENTATION.md

    mode: tunnel```bash

    protocol: esp-ahpython3 controller/validator.py

    local_subnet: 10.2.0.0/24```

    remote_subnet: 192.168.3.0/24

    peer_ip: 203.0.113.40### Deploy Policy

``````bash

# Linux/macOS

## Usagesudo python3 controller/policy_engine.py



### Validate Configuration# Windows

```bashpython "C:\Program Files\UnifiedIPsec\controller\policy_engine.py"

python3 controller/validator.py```

```

### View Status

### Deploy Policy```bash

```bash# Linux

# Linux/macOSsudo systemctl status unified-ipsec

sudo python3 controller/policy_engine.pysudo journalctl -u unified-ipsec -f



# Windows# Windows

python "C:\Program Files\UnifiedIPsec\controller\policy_engine.py"Get-ScheduledTask -TaskName UnifiedIPsec

```

# macOS

### View Status and Logssudo launchctl list | grep unifiedipsec

```bash```

# Linux - Service status

sudo systemctl status unified-ipsec### View Logs

sudo journalctl -u unified-ipsec -f```bash

# Linux/macOS

# Linux/macOS - Application logstail -f logs/ipsec.log

tail -f logs/ipsec.log

# Windows

# Windows - Task statusGet-Content "C:\Program Files\UnifiedIPsec\logs\ipsec.log" -Tail 50 -Wait

Get-ScheduledTask -TaskName UnifiedIPsec```



# macOS - Daemon status## Supported Configurations

sudo launchctl list | grep unifiedipsec

```### IPsec Modes

- ✅ **Tunnel Mode** (site-to-site, subnet-to-subnet)

## Testing- ✅ **Transport Mode** (host-to-host)



### Demo (Non-Destructive)### IPsec Protocols

```bash- ✅ **ESP** (Encapsulating Security Payload) - encryption + integrity

./demo.sh- ✅ **AH** (Authentication Header) - integrity only

```- ✅ **ESP+AH** (Combined) - encryption + dual authentication



### Test Encrypted Traffic (Linux)### Encryption Algorithms

```bash- AES-128, AES-192, AES-256, 3DES

# Terminal 1: Monitor ESP packets

sudo tcpdump -i any esp### Integrity Algorithms

- SHA-1, SHA-256, SHA-384, SHA-512, MD5

# Terminal 2: Configure and deploy

sudo python3 controller/policy_engine.py### Key Exchange

- IKEv1, IKEv2

# Terminal 3: Generate traffic through tunnel- DH Groups: 2, 5, 14, 15, 16, 17, 18, 19, 20, 21

ping <remote_subnet_ip>

### Authentication Methods

# Terminal 1 should show ESP packets indicating encryption- Pre-Shared Key (PSK)

```- Certificate-based (structure supported)



## Supported Configurations## 🔍 Troubleshooting



| Category | Supported |### Linux

|----------|-----------|

| **IPsec Modes** | Tunnel, Transport |**Problem:** strongSwan not installed

| **Protocols** | ESP, AH, ESP+AH |```bash

| **Encryption** | AES-128, AES-192, AES-256, 3DES |# Ubuntu/Debian

| **Integrity** | SHA-1, SHA-256, SHA-384, SHA-512, MD5 |sudo apt-get install strongswan

| **Key Exchange** | IKEv1, IKEv2 |

| **DH Groups** | 2, 5, 14, 15, 16, 17, 18, 19, 20, 21 |# CentOS/RHEL

| **Authentication** | PSK (fully), Certificates (structure) |sudo yum install strongswan

```

## Limitations

**Problem:** Tunnel not establishing

- **macOS adapter** is a prototype stub demonstrating concepts```bash

- **Certificate authentication** structure exists, adapters need extension# Check strongSwan status

- **AH protocol** validator accepts it, adapters need implementationsudo ipsec status

- **Linux-focused**: Primary development on strongSwan

# View detailed logs

## File Structuresudo journalctl -u strongswan -f



```# Verify configuration

controller/sudo ipsec verify

├── policy.yaml              # Unified policy definition```

├── policy_engine.py         # Main orchestrator

└── validator.py             # Configuration validator**Problem:** Permission denied

```bash

adapters/# Ensure running as root

├── linux/strongswan_adapter.pysudo unified-ipsec

├── windows/windows_ipsec.ps1```

├── macos/macos_ipsec.sh

└── boss_os/boss_adapter.py### Windows



installer/**Problem:** PowerShell execution policy

├── install_linux.sh```powershell

├── install_windows.ps1Set-ExecutionPolicy -ExecutionPolicy Bypass -Scope Process

└── install_macos.sh```



services/**Problem:** IPsec rules not applying

└── unified-ipsec.service    # systemd auto-start```powershell

# Check Windows Firewall service

demo.sh                       # Non-destructive demoGet-Service mpssvc

logs/                         # Runtime logs

```# View IPsec rules

Get-NetIPsecRule

## License

# Check IPsec SAs

MIT License - see LICENSE file for detailsGet-NetIPsecMainModeSA

Get-NetIPsecQuickModeSA

## Contributing```



Contributions welcome! Focus areas:**Problem:** Python not found

- macOS adapter completion- Install Python 3 from https://www.python.org/

- Certificate-based authentication- Check "Add Python to PATH" during installation

- Windows advanced IPsec configurations

- Performance optimization### macOS

- Additional OS support

**Problem:** LaunchDaemon not starting

## Quick Start```bash

# Check daemon status

1. **Install**: Run installer for your OSsudo launchctl list | grep unifiedipsec

2. **Configure**: Edit `policy.yaml`

3. **Validate**: Run `python3 controller/validator.py`# View daemon logs

4. **Deploy**: Run `python3 controller/policy_engine.py`cat /usr/local/unified-ipsec/logs/stderr.log

5. **Verify**: Check logs and tunnel status```



For detailed information, see QUICKSTART.md**Problem:** jq not found

```bash
# Install via Homebrew
brew install jq
```

## 📝 Logging

All operations are logged for troubleshooting:

**Linux:**
- Application log: `/opt/unified-ipsec/logs/ipsec.log`
- System log: `journalctl -u unified-ipsec`
- strongSwan log: `/var/log/syslog` or `journalctl -u strongswan`

**Windows:**
- Application log: `C:\Program Files\UnifiedIPsec\logs\ipsec.log`
- Windows adapter log: `C:\Program Files\UnifiedIPsec\logs\windows_ipsec.log`

**macOS:**
- Application log: `/usr/local/unified-ipsec/logs/ipsec.log`
- LaunchDaemon stdout: `/usr/local/unified-ipsec/logs/stdout.log`
- LaunchDaemon stderr: `/usr/local/unified-ipsec/logs/stderr.log`

## ⚠️ Limitations & Known Issues

### Current Limitations

1. **macOS Adapter is a Stub**
   - Demonstrates concepts but doesn't configure real IPsec
   - Production use requires racoon or IKEv2 profile implementation

2. **Windows PSK Configuration**
   - PowerShell creates firewall rules
   - Advanced PSK setup may require `netsh advfirewall consec` commands

3. **Certificate Authentication**
   - Structure supports it, but adapters need extension
   - Currently only PSK is fully implemented

4. **AH Protocol**
   - Validator accepts it, but adapters need implementation

5. **No GUI**
   - Command-line only for hackathon scope

### Security Considerations

⚠️ **This is a hackathon prototype, NOT production-ready software!**

**Do not use in production without:**
- Security audit
- Proper key management (not plaintext PSKs)
- Certificate-based authentication
- Monitoring and alerting
- Comprehensive testing
- Compliance validation

## 🚧 Future Enhancements

### Near-term
- [ ] Complete macOS adapter implementation
- [ ] Certificate-based authentication
- [ ] Web-based GUI for policy management
- [ ] Real-time tunnel status dashboard
- [ ] Automatic key rotation

### Long-term
- [ ] Integration with cloud providers (AWS, Azure, GCP)
- [ ] Kubernetes NetworkPolicy integration
- [ ] Central management server for fleet deployment
- [ ] Compliance reporting (PCI-DSS, HIPAA, etc.)
- [ ] High-availability configurations
- [ ] Dynamic routing protocol support (BGP, OSPF)

## 🤝 Contributing

This is a hackathon prototype! Contributions welcome:

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Submit a pull request

Priority areas:
- macOS adapter completion
- Certificate authentication
- Windows advanced configurations
- Test coverage
- Documentation

## 📄 License

MIT License - see LICENSE file for details

## 🙏 Acknowledgments

- **strongSwan** - Excellent open-source IPsec implementation
- **Microsoft** - Windows IPsec PowerShell cmdlets
- **Apple** - macOS networking stack

## 📚 References

- [strongSwan Documentation](https://wiki.strongswan.org/)
- [RFC 4301 - Security Architecture for IP](https://tools.ietf.org/html/rfc4301)
- [RFC 7296 - IKEv2](https://tools.ietf.org/html/rfc7296)
- [Windows IPsec Documentation](https://docs.microsoft.com/en-us/windows/security/threat-protection/windows-firewall/ipsec)

## 🎬 Project Info

**Created:** January 2026  
**Status:** Hackathon Prototype  
**Primary Focus:** Linux (strongSwan)  
**Secondary Focus:** Windows  
**Demo Status:** macOS (stub only)

---

**Built with ❤️ for network administrators everywhere!**
