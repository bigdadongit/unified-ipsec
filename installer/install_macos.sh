#!/bin/bash
# macOS Installer for Unified IPsec
# Installs and configures the unified IPsec solution on macOS systems

set -e

echo "========================================"
echo "Unified IPsec - macOS Installer"
echo "========================================"
echo ""

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Check if running as root
if [ "$EUID" -ne 0 ]; then
    echo -e "${RED}ERROR: This installer must be run as root${NC}"
    echo "Please run: sudo $0"
    exit 1
fi

echo -e "${GREEN}✓ Running as root${NC}"

# Determine installation directory
INSTALL_DIR="/usr/local/unified-ipsec"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"

echo "Installation directory: $INSTALL_DIR"
echo "Source directory: $PROJECT_ROOT"
echo ""

# Check dependencies
echo "Checking dependencies..."

# Check Python 3
if ! command -v python3 &> /dev/null; then
    echo -e "${RED}✗ Python 3 not found${NC}"
    echo "Please install Python 3:"
    echo "  1. Install Homebrew: /bin/bash -c \"\$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)\""
    echo "  2. Install Python: brew install python3"
    exit 1
fi
echo -e "${GREEN}✓ Python 3 installed${NC}"

# Check PyYAML
if ! python3 -c "import yaml" &> /dev/null; then
    echo -e "${YELLOW}⚠ PyYAML not found, installing...${NC}"
    pip3 install pyyaml
fi
echo -e "${GREEN}✓ PyYAML installed${NC}"

# Check for jq (helpful for macOS adapter)
if ! command -v jq &> /dev/null; then
    echo -e "${YELLOW}⚠ jq not found (recommended for macOS adapter)${NC}"
    echo "Install with: brew install jq"
fi

echo ""
echo "Creating installation directory..."

# Create installation directory
mkdir -p "$INSTALL_DIR"
mkdir -p "$INSTALL_DIR/logs"

# Copy files
echo "Copying files..."
cp -r "$PROJECT_ROOT/controller" "$INSTALL_DIR/"
cp -r "$PROJECT_ROOT/adapters" "$INSTALL_DIR/"
cp -r "$PROJECT_ROOT/logs" "$INSTALL_DIR/" 2>/dev/null || mkdir -p "$INSTALL_DIR/logs"

# Make scripts executable
chmod +x "$INSTALL_DIR/controller/policy_engine.py"
chmod +x "$INSTALL_DIR/adapters/linux/strongswan_adapter.py"
chmod +x "$INSTALL_DIR/adapters/macos/macos_ipsec.sh"

echo -e "${GREEN}✓ Files copied to $INSTALL_DIR${NC}"

# Create LaunchDaemon for auto-start
echo ""
echo "Creating LaunchDaemon for auto-start..."

PLIST_FILE="/Library/LaunchDaemons/com.unifiedipsec.plist"
cat > "$PLIST_FILE" <<EOF
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>Label</key>
    <string>com.unifiedipsec</string>
    <key>ProgramArguments</key>
    <array>
        <string>/usr/bin/python3</string>
        <string>$INSTALL_DIR/controller/policy_engine.py</string>
    </array>
    <key>RunAtLoad</key>
    <true/>
    <key>KeepAlive</key>
    <dict>
        <key>SuccessfulExit</key>
        <false/>
    </dict>
    <key>StandardOutPath</key>
    <string>$INSTALL_DIR/logs/stdout.log</string>
    <key>StandardErrorPath</key>
    <string>$INSTALL_DIR/logs/stderr.log</string>
</dict>
</plist>
EOF

chmod 644 "$PLIST_FILE"
echo -e "${GREEN}✓ LaunchDaemon created${NC}"

# Ask if user wants to load the daemon
echo ""
echo "Do you want to load the LaunchDaemon now? (y/n)"
read -r response
if [[ "$response" =~ ^[Yy]$ ]]; then
    launchctl load "$PLIST_FILE"
    echo -e "${GREEN}✓ LaunchDaemon loaded${NC}"
else
    echo -e "${YELLOW}⚠ LaunchDaemon not loaded${NC}"
    echo "Load later with: sudo launchctl load $PLIST_FILE"
fi

# Create symlink for easy access
echo ""
echo "Creating command-line shortcut..."
ln -sf "$INSTALL_DIR/controller/policy_engine.py" /usr/local/bin/unified-ipsec
echo -e "${GREEN}✓ You can now run: unified-ipsec${NC}"

# Summary
echo ""
echo "========================================"
echo -e "${GREEN}✓ Installation Complete!${NC}"
echo "========================================"
echo ""
echo "Next steps:"
echo "1. Edit policy: $INSTALL_DIR/controller/policy.yaml"
echo "2. Run manually: unified-ipsec"
echo "3. Or daemon will run on next boot"
echo "4. View logs: tail -f $INSTALL_DIR/logs/ipsec.log"
echo ""
echo "LaunchDaemon commands:"
echo "  Load:    sudo launchctl load $PLIST_FILE"
echo "  Unload:  sudo launchctl unload $PLIST_FILE"
echo "  Start:   sudo launchctl start com.unifiedipsec"
echo "  Stop:    sudo launchctl stop com.unifiedipsec"
echo ""
echo "IMPORTANT: The macOS adapter is a prototype stub."
echo "Full IPsec configuration requires additional development."
echo ""
