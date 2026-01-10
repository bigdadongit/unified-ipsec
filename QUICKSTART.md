# Quick Start Guide

Get up and running with Unified IPsec in 5 minutes.

## Prerequisites

- Python 3.6+
- Root/Administrator access (for actual deployment)

## Option 1: Non-Destructive Demo

Run without making any system changes:

```bash
cd unified-ipsec
chmod +x demo.sh
./demo.sh
```

This will:
1. ✓ Validate your policy
2. ✓ Show what would be deployed
3. ✓ Generate platform-specific commands
4. ✓ Log everything to `logs/ipsec.log`

## Option 2: Install System-Wide

### Linux (Ubuntu/Debian/CentOS/RHEL)

```bash
sudo ./installer/install_linux.sh
```

### Windows (PowerShell as Administrator)

```powershell
.\installer\install_windows.ps1
```

### macOS

```bash
sudo ./installer/install_macos.sh
```

## Configure Your Policy

Edit `controller/policy.yaml`:

```yaml
global:
  ike_version: ikev2
  auth_method: psk
  psk: "your_shared_key"
  encryption: aes256
  integrity: sha256

tunnels:
  - name: my_tunnel
    mode: tunnel
    peer_ip: 203.0.113.10
    local_subnet: 10.0.0.0/24
    remote_subnet: 192.168.1.0/24
```

## Validate Your Configuration

```bash
python3 controller/validator.py
```

Expected output: `✓ Validation passed`

## Deploy

After installation, deploy with:

```bash
# Linux
sudo unified-ipsec deploy

# Windows (PowerShell)
& "C:\Program Files\unified-ipsec\policy_engine.ps1"

# macOS
sudo /opt/unified-ipsec/policy_engine.py
```

## Verify Tunnels

### Linux
```bash
ipsec status
ip xfrm state
ip xfrm policy
```

### Windows
```powershell
Get-NetIPsecRule
Get-NetIPsecPhase1AuthSet
```

### macOS
```bash
setkey -D
setkey -DP
```

## View Logs

```bash
# Linux/macOS
tail -f logs/ipsec.log

# Windows
Get-Content "C:\Program Files\unified-ipsec\logs\ipsec.log" -Tail 50
```

## Next Steps

- Read [README.md](README.md) for full documentation
- Check [CONTRIBUTING.md](CONTRIBUTING.md) to contribute
- Review `controller/policy.yaml` for configuration options
