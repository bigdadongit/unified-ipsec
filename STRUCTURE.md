# Project Structure

```
unified-ipsec/
├── adapters/                      # Platform-specific adapters
│   ├── linux/
│   │   └── strongswan_adapter.py  # Linux/strongSwan implementation
│   ├── windows/
│   │   └── windows_ipsec.ps1      # Windows PowerShell implementation
│   ├── macos/
│   │   └── macos_ipsec.sh         # macOS prototype stub
│   └── boss_os/
│       └── boss_adapter.py        # Boss OS implementation
│
├── controller/                    # Core policy engine
│   ├── policy.yaml               # Unified policy definition
│   ├── policy_engine.py          # Main orchestrator
│   └── validator.py              # Policy validation
│
├── installer/                    # Installation scripts
│   ├── install_linux.sh          # Linux installer
│   ├── install_windows.ps1       # Windows installer
│   └── install_macos.sh          # macOS installer
│
├── services/                     # Systemd service files
│   └── unified-ipsec.service     # Auto-start service
│
├── logs/                         # Runtime logs and temporary files
│   └── .gitkeep
│
├── demo.sh                       # Non-destructive demo
├── requirements.txt              # Python dependencies
├── .gitignore                    # Git ignore rules
├── LICENSE                       # MIT License
├── README.md                     # Main documentation
├── QUICKSTART.md                 # Quick start guide
├── CONTRIBUTING.md               # Contribution guidelines
└── STRUCTURE.md                  # This file
```

## File Descriptions

### Controllers
- **policy.yaml**: YAML configuration defining IPsec tunnels and global settings
- **policy_engine.py**: Main orchestrator that loads policy, validates it, detects OS, and calls adapters
- **validator.py**: Validates policy.yaml syntax and required fields

### Adapters
- **strongswan_adapter.py**: Generates `/etc/ipsec.conf` for strongSwan on Linux
- **windows_ipsec.ps1**: Creates Windows IPsec rules via PowerShell
- **macos_ipsec.sh**: Prototype for macOS setkey/racoon configuration
- **boss_adapter.py**: Boss OS implementation

### Installation
- **install_linux.sh**: Installs dependencies, creates /opt/unified-ipsec, sets up systemd service
- **install_windows.ps1**: Installs to Program Files, registers scheduled task
- **install_macos.sh**: Installs to /opt/unified-ipsec, creates launchd plist

### Demo & Testing
- **demo.sh**: Non-destructive demo showing what would happen
- **requirements.txt**: Python dependencies (PyYAML)

## Architecture Pattern

```
User writes policy.yaml
         ↓
policy_engine.py loads & validates
         ↓
Detects OS (Linux/Windows/macOS/Boss OS)
         ↓
Calls appropriate adapter
         ↓
Adapter generates platform-specific config
         ↓
Logs all operations
         ↓
Returns status to user
```

## Development Guidelines

### Adding New Platform Support

1. Create new directory: `adapters/newos/`
2. Implement adapter script/module with functions:
   - `load_policy(policy_path)`
   - `validate_config()`
   - `apply_config()`
3. Update `policy_engine.py` to detect and call new adapter
4. Create installer: `installer/install_newos.sh`
5. Document in README.md

### Policy Schema

See `controller/policy.yaml` for schema. Key sections:
- **global**: IKE version, authentication, encryption settings
- **tunnels**: List of IPsec tunnels with mode (tunnel/transport)

### Logging

All operations logged to `logs/ipsec.log` with timestamps and log levels.
