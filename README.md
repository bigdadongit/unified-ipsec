# Unified Cross-Platform IPsec Solution# Unified Cross-Platform IPsec Solution



[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)

![Python 3.6+](https://img.shields.io/badge/python-3.6+-blue.svg)![Python 3.6+](https://img.shields.io/badge/python-3.6+-blue.svg)



A unified IPsec solution for enterprises to automatically encrypt network traffic across Windows, Linux (Ubuntu/Debian/RHEL/BOSS), and macOS using centrally defined policies.A unified IPsec solution for enterprises to automatically encrypt network traffic across Windows, Linux (Ubuntu/Debian/RHEL/BOSS), and macOS using centrally defined policies.



## Problem Statement## Problem Statement



Enterprise networks consist of diverse operating systems (Windows, Linux, macOS, BOSS) requiring consistent encryption policies. Currently:Enterprise networks consist of diverse operating systems (Windows, Linux, macOS, BOSS) requiring consistent encryption policies. Currently:

- **Linux** uses strongSwan with `ipsec.conf`- **Linux** uses strongSwan with `ipsec.conf`

- **Windows** uses PowerShell cmdlets and IPsec rules- **Windows** uses PowerShell cmdlets and IPsec rules

- **macOS** uses racoon or IKEv2 profiles- **macOS** uses racoon or IKEv2 profiles

- **BOSS OS** requires custom kernel module integration- **BOSS OS** requires custom kernel module integration



This fragmentation leads to configuration inconsistencies, security gaps, deployment delays, and operational complexity.This fragmentation leads to:

- Configuration inconsistencies and security gaps

## Solution- Deployment delays and operational complexity

- Manual configuration on each device

**Unified IPsec** provides:- Lack of centralized policy management

1. **Single policy file** (`policy.yaml`) deployed across all operating systems

2. **Automatic encryption** of traffic based on centrally defined policies## Solution

3. **Zero-touch deployment** with auto-start on boot

4. **Complete IPsec mode support** (ESP Tunnel, ESP Transport, AH Tunnel, AH Transport, ESP+AH)**Unified IPsec** provides:

5. **Multi-tunnel capability** for different peers and subnets1. **Single policy file** (`policy.yaml`) deployed to all operating systems

6. **Comprehensive logging** for tunnel status and troubleshooting2. **Automatic encryption** of traffic based on centrally defined policies

3. **Zero-touch deployment** with auto-start on boot

## Architecture4. **Complete IPsec mode support** (ESP Tunnel, ESP Transport, AH Tunnel, AH Transport, ESP+AH)

5. **Multi-tunnel capability** for different peers and subnets

```

Policy Definition (policy.yaml)## Architecture

          ↓

Policy Engine (policy_engine.py)```

          ↓┌──────────────────────────────┐

    Platform Detection│   policy.yaml (Unified)      │

          ↓│  - IPsec modes & protocols   │

    ┌─────┬─────┬──────┐│  - Encryption algorithms     │

    ▼     ▼     ▼      ▼│  - Authentication methods    │

  Linux Windows macOS BOSS OS└────────────┬─────────────────┘

```             │

             ▼

**Components:**┌──────────────────────────────┐

- **controller/policy.yaml** - Unified IPsec policy definition│  policy_engine.py            │

- **controller/policy_engine.py** - Orchestrator and validator│  - Loads & validates policy  │

- **adapters/** - OS-specific implementations│  - Detects OS                │

- **installer/** - Automated deployment scripts│  - Calls adapter             │

- **services/** - Auto-start configurations│  - Logs tunnel status        │

└────────────┬─────────────────┘

## Key Features             │

    ┌────────┼────────┬──────────┐

✅ **All IPsec Modes Supported**    ▼        ▼        ▼          ▼

- Tunnel mode (site-to-site)  Linux   Windows  macOS      BOSS OS

- Transport mode (host-to-host)strongSwan PowerShell setkey  IKE Module

- AH (authentication-only)```

- ESP+AH (combined encryption and authentication)

### Components

✅ **Flexible Configuration**

- IKEv1 and IKEv2 support- **controller/policy.yaml** - Unified policy definition

- Multiple encryption algorithms (AES-128, AES-192, AES-256, 3DES)- **controller/policy_engine.py** - Main orchestrator

- Multiple integrity algorithms (SHA-1, SHA-256, SHA-384, SHA-512, MD5)- **controller/validator.py** - Configuration validation

- PSK and certificate-based authentication (PSK fully implemented)- **adapters/** - OS-specific implementations

- Configurable DH groups- **installer/** - Deployment scripts

- **services/unified-ipsec.service** - Linux auto-start

✅ **Automatic Operation**

- Auto-start on system boot## Installation

- Automatic tunnel initialization and recovery

- Comprehensive logging of tunnel status and events### Linux (Ubuntu/Debian/CentOS/RHEL)

- Configuration validation before deployment```bash

cd unified-ipsec

✅ **Cross-Platform**sudo ./installer/install_linux.sh

- Single policy for all operating systems```

- Platform-specific adapters handle OS differences

- Uniform security parameters across network### Windows (PowerShell as Administrator)

```powershell

## Installationcd unified-ipsec

Set-ExecutionPolicy -ExecutionPolicy Bypass -Scope Process

### Linux (Ubuntu/Debian/CentOS/RHEL/BOSS).\installer\install_windows.ps1

```bash```

cd unified-ipsec

sudo ./installer/install_linux.sh### macOS

``````bash

cd unified-ipsec

### Windows (PowerShell as Administrator)sudo ./installer/install_macos.sh

```powershell```

cd unified-ipsec

Set-ExecutionPolicy -ExecutionPolicy Bypass -Scope Process## Configuration

.\installer\install_windows.ps1

```Edit `controller/policy.yaml`:



### macOS```yaml

```bashglobal:

cd unified-ipsec  ike_version: ikev2

sudo ./installer/install_macos.sh  auth_method: psk

```  psk: "shared_secret_key"

  encryption: aes256

## Configuration  integrity: sha256

  dh_group: 14

Edit `controller/policy.yaml` to define your IPsec policies:  auto_start: true



```yamltunnels:

global:  # Site-to-site tunnel (ESP Tunnel Mode)

  ike_version: ikev2           # IKE protocol version  - name: site_to_site

  auth_method: psk             # Authentication method    mode: tunnel

  psk: "shared_secret_key"     # Pre-shared key    protocol: esp

  encryption: aes256           # Encryption algorithm    local_subnet: 10.0.0.0/24

  integrity: sha256            # Integrity algorithm    remote_subnet: 192.168.1.0/24

  dh_group: 14                 # Diffie-Hellman group    peer_ip: 203.0.113.10

  auto_start: true             # Auto-start on boot

  # Host-to-host (ESP Transport Mode)

tunnels:  - name: host_to_host

  # Site-to-site tunnel (ESP Tunnel Mode)    mode: transport

  - name: site_to_site    protocol: esp

    mode: tunnel    peer_ip: 203.0.113.20

    protocol: esp

    local_subnet: 10.0.0.0/24  # AH Tunnel Mode (authentication-only)

    remote_subnet: 192.168.1.0/24  - name: auth_tunnel

    peer_ip: 203.0.113.10    mode: tunnel

    protocol: ah

  # Host-to-host (ESP Transport Mode)    local_subnet: 10.1.0.0/24

  - name: host_to_host    remote_subnet: 192.168.2.0/24

    mode: transport    peer_ip: 203.0.113.30

    protocol: esp

    peer_ip: 203.0.113.20  # ESP + AH Combined (encryption + dual authentication)

  - name: combined_tunnel

  # AH Tunnel Mode (authentication-only)    mode: tunnel

  - name: auth_tunnel    protocol: esp-ah

    mode: tunnel    local_subnet: 10.2.0.0/24

    protocol: ah    remote_subnet: 192.168.3.0/24

    local_subnet: 10.1.0.0/24    peer_ip: 203.0.113.40

    remote_subnet: 192.168.2.0/24```

    peer_ip: 203.0.113.30

## Usage

  # ESP + AH Combined

  - name: combined_tunnel### Validate Configuration

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
