# Unified Cross-Platform IPsec Solution

![License](https://img.shields.io/badge/license-MIT-blue.svg)
![Status](https://img.shields.io/badge/status-hackathon%20prototype-yellow.svg)

A hackathon prototype that enables network administrators to define IPsec security policies **once** and automatically deploy them across Linux, Windows, and macOS systems.

## 🎯 Problem Statement

Managing IPsec configurations across heterogeneous operating systems is painful:

- **Linux** uses strongSwan with `ipsec.conf`
- **Windows** uses PowerShell cmdlets and Group Policy
- **macOS** uses racoon or IKEv2 profiles

Network administrators must maintain separate configurations for each platform, leading to:
- Configuration drift
- Human error
- Increased operational complexity
- Security policy inconsistencies

## 💡 Our Solution

**Unified IPsec** provides:
1. **Single policy file** (`policy.yaml`) that works across all platforms
2. **Automatic translation** to platform-specific configurations
3. **Zero-touch deployment** with auto-start on boot
4. **Simple architecture** designed for rapid prototyping

## 🏗️ Architecture

```
┌─────────────────────────────────────────────────┐
│           policy.yaml (Unified Policy)          │
│  - Global settings (IKE, PSK, crypto)          │
│  - Tunnel definitions (tunnel/transport)       │
└────────────────┬────────────────────────────────┘
                 │
                 ▼
┌─────────────────────────────────────────────────┐
│        policy_engine.py (Orchestrator)          │
│  - Loads & validates policy                    │
│  - Detects operating system                    │
│  - Calls appropriate adapter                   │
│  - Logs all operations                         │
└────────────────┬────────────────────────────────┘
                 │
       ┌─────────┴─────────┬──────────────┐
       ▼                   ▼              ▼
┌─────────────┐  ┌──────────────┐  ┌─────────────┐
│   Linux     │  │   Windows    │  │    macOS    │
│  Adapter    │  │   Adapter    │  │   Adapter   │
│             │  │              │  │   (stub)    │
│ strongSwan  │  │ PowerShell   │  │             │
│ ipsec.conf  │  │ IPsec Rules  │  │   setkey    │
└─────────────┘  └──────────────┘  └─────────────┘
```

### Components

#### 1. **Controller** (`controller/`)
- `policy.yaml` - Unified policy definition
- `policy_engine.py` - Main orchestrator
- `validator.py` - Policy validation logic

#### 2. **Adapters** (`adapters/`)
- `linux/strongswan_adapter.py` - Generates strongSwan configs
- `windows/windows_ipsec.ps1` - Creates Windows IPsec rules
- `macos/macos_ipsec.sh` - Prototype stub for macOS

#### 3. **Installer** (`installer/`)
- `install_linux.sh` - Linux installation script
- `install_windows.ps1` - Windows installation script
- `install_macos.sh` - macOS installation script

#### 4. **Services** (`services/`)
- `unified-ipsec.service` - systemd service for auto-start

## 📦 Installation

### Linux (Ubuntu/Debian/CentOS/RHEL)

```bash
# Clone or extract the project
cd unified-ipsec

# Run installer as root
sudo ./installer/install_linux.sh
```

**What it does:**
- Installs Python 3 and PyYAML (if needed)
- Optionally installs strongSwan
- Copies files to `/opt/unified-ipsec`
- Creates systemd service
- Adds `unified-ipsec` command to PATH

### Windows (PowerShell as Administrator)

```powershell
# Navigate to project directory
cd unified-ipsec

# Allow script execution (if needed)
Set-ExecutionPolicy -ExecutionPolicy Bypass -Scope Process

# Run installer
.\installer\install_windows.ps1
```

**What it does:**
- Checks for Python 3 and PyYAML
- Copies files to `C:\Program Files\UnifiedIPsec`
- Creates scheduled task for auto-start
- Adds to system PATH

### macOS

```bash
# Clone or extract the project
cd unified-ipsec

# Run installer as root
sudo ./installer/install_macos.sh
```

**What it does:**
- Checks for Python 3 and PyYAML
- Copies files to `/usr/local/unified-ipsec`
- Creates LaunchDaemon for auto-start
- Adds `unified-ipsec` command to PATH

## 🚀 Usage

### 1. Edit Policy

Edit the unified policy file:

**Linux/macOS:**
```bash
sudo nano /opt/unified-ipsec/controller/policy.yaml
# or
sudo nano /usr/local/unified-ipsec/controller/policy.yaml
```

**Windows:**
```powershell
notepad "C:\Program Files\UnifiedIPsec\controller\policy.yaml"
```

### 2. Policy Format

```yaml
global:
  ike_version: ikev2          # IKE version
  auth_method: psk            # Authentication method
  psk: "demo_shared_key"      # Pre-shared key
  encryption: aes256          # Encryption algorithm
  integrity: sha256           # Integrity algorithm
  dh_group: 14                # Diffie-Hellman group
  auto_start: true            # Start tunnels automatically

tunnels:
  - name: site_to_site        # Tunnel name
    mode: tunnel              # tunnel or transport
    protocol: esp             # esp or ah
    local_subnet: 10.0.0.0/24
    remote_subnet: 192.168.1.0/24
    peer_ip: 203.0.113.10

  - name: host_to_host
    mode: transport
    protocol: esp
    peer_ip: 203.0.113.20
```

### 3. Run Manually

**Linux:**
```bash
sudo unified-ipsec
# or
sudo python3 /opt/unified-ipsec/controller/policy_engine.py
```

**Windows (as Administrator):**
```powershell
unified-ipsec.bat
# or
python "C:\Program Files\UnifiedIPsec\controller\policy_engine.py"
```

**macOS:**
```bash
sudo unified-ipsec
# or
sudo python3 /usr/local/unified-ipsec/controller/policy_engine.py
```

### 4. Service Management

**Linux (systemd):**
```bash
# Start service
sudo systemctl start unified-ipsec

# Enable auto-start
sudo systemctl enable unified-ipsec

# Check status
sudo systemctl status unified-ipsec

# View logs
sudo journalctl -u unified-ipsec -f
```

**Windows (Scheduled Task):**
```powershell
# Start task
Start-ScheduledTask -TaskName "UnifiedIPsec"

# Check status
Get-ScheduledTask -TaskName "UnifiedIPsec" | Get-ScheduledTaskInfo

# View logs
Get-Content "C:\Program Files\UnifiedIPsec\logs\ipsec.log" -Tail 50 -Wait
```

**macOS (LaunchDaemon):**
```bash
# Load daemon
sudo launchctl load /Library/LaunchDaemons/com.unifiedipsec.plist

# Start manually
sudo launchctl start com.unifiedipsec

# View logs
tail -f /usr/local/unified-ipsec/logs/ipsec.log
```

## 🧪 Demo: Testing Encrypted Traffic

### Scenario: Site-to-Site Tunnel

1. **Setup two Linux VMs** (or cloud instances)
   - VM1: 10.0.0.10 (local subnet: 10.0.0.0/24)
   - VM2: 192.168.1.10 (remote subnet: 192.168.1.0/24)

2. **Install on both VMs:**
   ```bash
   sudo ./installer/install_linux.sh
   ```

3. **Configure VM1** (`policy.yaml`):
   ```yaml
   global:
     ike_version: ikev2
     auth_method: psk
     psk: "shared_secret_key_123"
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
       peer_ip: <VM2_PUBLIC_IP>
   ```

4. **Configure VM2** (mirror configuration):
   ```yaml
   tunnels:
     - name: site_to_site
       mode: tunnel
       protocol: esp
       local_subnet: 192.168.1.0/24
       remote_subnet: 10.0.0.0/24
       peer_ip: <VM1_PUBLIC_IP>
   ```

5. **Apply configuration:**
   ```bash
   # On both VMs
   sudo unified-ipsec
   ```

6. **Verify tunnel establishment:**
   ```bash
   # Check IPsec status
   sudo ipsec status

   # Monitor traffic
   sudo tcpdump -i any esp
   ```

7. **Test encrypted connectivity:**
   ```bash
   # From VM1, ping VM2's private IP
   ping 192.168.1.10

   # You should see ESP packets in tcpdump
   ```

### Scenario: Transport Mode (Host-to-Host)

1. **Configure for direct host encryption:**
   ```yaml
   tunnels:
     - name: secure_comms
       mode: transport
       protocol: esp
       peer_ip: <REMOTE_HOST_IP>
   ```

2. **Run on both hosts:**
   ```bash
   sudo unified-ipsec
   ```

3. **Test:**
   ```bash
   # SSH should now be encrypted within ESP
   ssh user@<REMOTE_HOST_IP>

   # Verify ESP traffic
   sudo tcpdump -i any esp
   ```

## 📊 Supported Configurations

### IKE Versions
- ✅ IKEv2 (primary)
- ⚠️ IKEv1 (structure supports, not fully tested)

### Authentication Methods
- ✅ Pre-shared Key (PSK)
- ⚠️ Certificates (structure supports, adapters need extension)

### Encryption Algorithms
- ✅ AES-128, AES-192, AES-256
- ✅ 3DES

### Integrity Algorithms
- ✅ SHA-1, SHA-256, SHA-384, SHA-512
- ✅ MD5

### DH Groups
- ✅ 2, 5, 14, 15, 16, 17, 18, 19, 20, 21

### Modes
- ✅ Tunnel mode (site-to-site)
- ✅ Transport mode (host-to-host)

### Protocols
- ✅ ESP (Encapsulating Security Payload)
- ⚠️ AH (Authentication Header - structure supports, not implemented)

## 🔍 Troubleshooting

### Linux

**Problem:** strongSwan not installed
```bash
# Ubuntu/Debian
sudo apt-get install strongswan

# CentOS/RHEL
sudo yum install strongswan
```

**Problem:** Tunnel not establishing
```bash
# Check strongSwan status
sudo ipsec status

# View detailed logs
sudo journalctl -u strongswan -f

# Verify configuration
sudo ipsec verify
```

**Problem:** Permission denied
```bash
# Ensure running as root
sudo unified-ipsec
```

### Windows

**Problem:** PowerShell execution policy
```powershell
Set-ExecutionPolicy -ExecutionPolicy Bypass -Scope Process
```

**Problem:** IPsec rules not applying
```powershell
# Check Windows Firewall service
Get-Service mpssvc

# View IPsec rules
Get-NetIPsecRule

# Check IPsec SAs
Get-NetIPsecMainModeSA
Get-NetIPsecQuickModeSA
```

**Problem:** Python not found
- Install Python 3 from https://www.python.org/
- Check "Add Python to PATH" during installation

### macOS

**Problem:** LaunchDaemon not starting
```bash
# Check daemon status
sudo launchctl list | grep unifiedipsec

# View daemon logs
cat /usr/local/unified-ipsec/logs/stderr.log
```

**Problem:** jq not found
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
