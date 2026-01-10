# 5-MINUTE DEMO GUIDE
## Unified Cross-Platform IPsec Solution

This guide walks through a complete demo of the solution in 5 minutes for hackathon evaluation.

---

## DEMO SETUP (Preparation - Do this before demo)

### Prerequisites
- 2 Linux VMs (or 1 Linux + Windows)
- Network connectivity between VMs
- Python 3.6+ installed on both
- `sudo` access

### Pre-demo Checklist
```bash
# On VM1 and VM2, install dependencies
sudo apt-get update
sudo apt-get install -y python3 python3-pip strongswan tcpdump jq

# Install Python YAML library
pip3 install pyyaml

# Clone/download unified-ipsec
git clone https://github.com/ski69per/unified-ipsec.git
cd unified-ipsec
```

---

## DEMO FLOW (5 minutes)

### ⏱️ MINUTE 1: Problem Statement + Solution

**What to show (1 minute):**

```
Say:
"Managing IPsec across different OSes is painful.
 Linux uses strongSwan, Windows uses PowerShell, macOS uses different tools.
 
 Administrators have to maintain separate configs for each OS.
 
 OUR SOLUTION: Write ONE policy file in YAML.
 The same policy automatically deploys to any OS."

Open files to show:
- controller/policy.yaml (single unified policy)
- adapters/ (platform-specific translators)
```

**Visual: Draw on whiteboard or point to README**
```
          policy.yaml
         (ONE file)
             ↓
    Policy Engine
             ↓
   ┌──────┬──────┬──────┐
   ↓      ↓      ↓      ↓
 Linux  Windows macOS Boss-OS
```

---

### ⏱️ MINUTE 2: Show the Policy File

**What to show (1 minute):**

```bash
# Terminal 1 (VM1)
cd unified-ipsec
cat controller/policy.yaml
```

**Point out to demo evaluator:**

```yaml
global:
  ike_version: ikev2      # ← Unified IKE config
  auth_method: psk
  psk: "demo_shared_key"
  encryption: aes256      # ← Unified encryption
  integrity: sha256
  dh_group: 14

tunnels:
  - name: site_to_site
    mode: tunnel          # ← EXPLICIT IPsec MODE
    protocol: esp         # ← EXPLICIT PROTOCOL
    local_subnet: 10.0.0.0/24
    remote_subnet: 192.168.1.0/24
    peer_ip: 203.0.113.10

  - name: host_to_host
    mode: transport       # ← Different mode
    protocol: esp
```

**Say:**
"See how the policy is **clear and simple**?
 - **Modes**: tunnel (site-to-site) AND transport (host-to-host)
 - **Protocols**: ESP for encryption
 - **Global config**: IKE, encryption, integrity - all in ONE place
 
 This same file will run on Linux, Windows, macOS, and Boss OS!"

---

### ⏱️ MINUTE 3: Validate & Show Configuration Parsing

**What to show (1 minute):**

```bash
# Terminal 1 (VM1)
python3 controller/validator.py
```

**Expected output:**
```
✓ Validation passed
```

**Then show the policy engine execution:**

```bash
# Terminal 1 (VM1)
sudo python3 controller/policy_engine.py 2>&1 | head -30
```

**Expected output shows:**
```
============================================================
UNIFIED IPSEC POLICY ENGINE STARTING
============================================================
Detected OS: linux
Loading policy from: /path/to/policy.yaml
Policy loaded successfully
Validating policy configuration...
✓ Policy validation passed

------------------------------------------------------------
IPsec Configuration Summary:
  IKE Version: IKEV2
  Encryption: aes256
  Integrity: sha256
  Auto-start: Yes

Tunnels:
  [✓ ENABLED] site_to_site
    Mode: TUNNEL | Protocol: ESP | Peer: 203.0.113.10
    Subnets: 10.0.0.0/24 <-> 192.168.1.0/24
    Type: Site-to-Site (Tunnel encapsulates entire IP packet)
    Security: Encryption + Integrity (ESP)

  [✓ ENABLED] host_to_host
    Mode: TRANSPORT | Protocol: ESP | Peer: 203.0.113.20
    Type: Host-to-Host (Transport mode, original IP header)
    Security: Encryption + Integrity (ESP)
```

**Say:**
"Notice how the engine **clearly shows what modes it's using**?
 - Tunnel mode for site-to-site (encapsulates packets)
 - Transport mode for host-to-host
 - **Both are configured from the SAME policy file**
 
 The key here: We validate before deployment. No errors = safe to deploy."

---

### ⏱️ MINUTE 4: Show Auto-Start Configuration

**What to show (30 seconds):**

```bash
# Show systemd auto-start for Linux
cat services/unified-ipsec.service
```

**Point out key lines:**
```ini
[Unit]
Description=Unified IPsec Policy Engine
After=network-online.target      # ← Runs after network is up

[Service]
ExecStart=/usr/bin/python3 /opt/unified-ipsec/controller/policy_engine.py
RemainAfterExit=yes
Restart=on-failure

[Install]
WantedBy=multi-user.target       # ← Auto-starts on boot
```

**Say:**
"This Linux systemd service **automatically runs at boot**.
 On Windows, it's a Scheduled Task.
 On macOS, it's a LaunchDaemon.
 
 **SAME POLICY FILE works across all platforms with platform-specific auto-start.**"

---

### ⏱️ MINUTE 4.5: Show Logging (Tunnel Status)

**What to show (30 seconds):**

```bash
# Show the generated log file
tail -20 logs/ipsec.log
```

**Expected:**
```
2026-01-10 16:18:00,738 [INFO] Tunnel Status After Deployment:
2026-01-10 16:18:00,738 [INFO] ✓ [CONFIGURED] Tunnel 'site_to_site' (tunnel) - ready to establish
2026-01-10 16:18:00,738 [INFO] ✓ [CONFIGURED] Tunnel 'host_to_host' (transport) - ready to establish
```

**Say:**
"The system logs **what tunnels are configured** and their status.
 In production, this would show:
 - SA ESTABLISHED (Security Association created)
 - REKEY events
 - Traffic stats
 - Errors"

---

### ⏱️ MINUTE 5: Demo Mode - Non-destructive Test

**What to show (1 minute):**

```bash
# Run demo.sh to show what would happen without making system changes
./demo.sh
```

**This shows:**
1. ✅ Validation passes
2. ✅ Policy loads
3. ✅ OS is detected
4. ✅ Adapter is called
5. ✅ Generated commands are shown

**If 2-VM setup available (BONUS):**
```bash
# Terminal 1 (VM1): Monitor ESP traffic
sudo tcpdump -i any esp -n

# Terminal 2 (VM2): In background, start unified-ipsec
sudo python3 controller/policy_engine.py

# Terminal 3 (VM1): Ping protected subnet
ping <VM2_PRIVATE_IP>

# Show the tcpdump output - see ESP packets!
```

**Say:**
"This is the **proof of encrypted traffic**.
 When you see ESP packets in tcpdump, it means:
 - Tunnel is UP
 - Traffic is being encrypted
 - Security Association (SA) is established"

---

## SUMMARY (What the demo proved)

```
✅ Unified policy file (ONE policy for all OSes)
✅ Explicit IPsec modes (tunnel AND transport)
✅ Explicit protocols (ESP, and structure for AH/ESP-AH)
✅ Validation before deployment (catch errors early)
✅ Auto-start on boot (systemd shown)
✅ Clear logging (tunnel status visible)
✅ Multi-platform support (same YAML works everywhere)
✅ Encrypted traffic proof (tcpdump shows ESP)
```

---

## QUICK REFERENCE DURING DEMO

### Common Questions & Answers

**Q: How is this different from other IPsec management tools?**
A: We focus on **simplicity** - one YAML file for all platforms.
   No need to learn strongSwan conf, PowerShell, or macOS-specific tools.

**Q: What about certificate authentication?**
A: Prototype uses PSK for simplicity. Certificate auth structure is there.

**Q: Is this production-ready?**
A: This is a hackathon prototype showing the concept.
   For production: add key management, monitoring, compliance checks.

**Q: Why show both tunnel and transport modes?**
A: To prove we support the full IPsec spec:
   - Tunnel: site-to-site gateways
   - Transport: direct host-to-host
   - **Both from the same policy**

**Q: What about Windows and macOS?**
A: Same policy file. Adapters translate to:
   - Windows: PowerShell IPsec cmdlets
   - macOS: setkey / IKEv2 profiles

---

## DEMO TIPS & TRICKS

1. **Keep it simple**: Stick to the flow. Don't get sidetracked.

2. **Show the logs**: Logs prove what happened. They're important.

3. **Emphasize the unified policy**: That's the innovation.

4. **Pre-test everything**: Run through the demo once before presenting.

5. **Have policy examples ready**: 
   ```bash
   cat POLICY_EXAMPLES.md
   ```
   Shows all modes.

6. **If demo breaks**: Fall back to demo.sh (non-destructive).

7. **Kill processes cleanly**:
   ```bash
   sudo pkill -f policy_engine
   ```

8. **Clean logs before demo**:
   ```bash
   rm logs/ipsec.log
   ```

---

## TIME BUDGET

| Phase | Time | Content |
|-------|------|---------|
| Problem + Solution | 1 min | Overview |
| Show Policy File | 1 min | YAML config |
| Validate & Parse | 1 min | Engine execution |
| Auto-start | 0.5 min | systemd service |
| Logging | 0.5 min | Tunnel status |
| Demo/Proof | 1 min | tcpdump or demo.sh |
| **Total** | **5 min** | **Complete** |

---

## SUCCESS CRITERIA

For a successful demo, evaluators will see:

✅ **MANDATORY:**
- [ ] Single policy file (policy.yaml) shown
- [ ] IPsec modes explicitly visible (tunnel, transport)
- [ ] Policy validation working
- [ ] Logging showing tunnel configuration
- [ ] Auto-start mechanism explained

✅ **BONUS:**
- [ ] Live encrypted traffic shown (tcpdump ESP)
- [ ] Multi-platform architecture explained
- [ ] Demo on 2+ OSes simultaneously
- [ ] Source code commentary visible

---

## REPO STRUCTURE FOR DEMO

```
unified-ipsec/
├── controller/
│   ├── policy.yaml          ← SHOW THIS (unified policy)
│   ├── policy_engine.py     ← SHOW THIS (orchestrator)
│   └── validator.py
├── adapters/
│   ├── linux/               ← MENTION (platform-specific)
│   ├── windows/
│   └── macos/
├── services/
│   └── unified-ipsec.service ← SHOW THIS (auto-start)
├── logs/
│   └── ipsec.log            ← SHOW THIS (logging)
├── demo.sh                  ← RUN THIS (non-destructive)
├── POLICY_EXAMPLES.md       ← REFERENCE
└── README.md
```

---

**Good luck with your demo! 🚀**
