#!/bin/bash
# Linux Installer for Unified IPsec
# Installs and configures the unified IPsec solution on Linux systems

set -e

echo "========================================"
echo "Unified IPsec - Linux Installer"
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
INSTALL_DIR="/opt/unified-ipsec"
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
    echo "Installing Python 3..."
    apt-get update && apt-get install -y python3 python3-pip || yum install -y python3 python3-pip
fi
echo -e "${GREEN}✓ Python 3 installed${NC}"

# Check PyYAML
if ! python3 -c "import yaml" &> /dev/null; then
    echo -e "${YELLOW}⚠ PyYAML not found, installing...${NC}"
    pip3 install pyyaml
fi
echo -e "${GREEN}✓ PyYAML installed${NC}"

# Check strongSwan
if ! command -v ipsec &> /dev/null; then
    echo -e "${YELLOW}⚠ strongSwan not found${NC}"
    echo "Do you want to install strongSwan? (y/n)"
    read -r response
    if [[ "$response" =~ ^[Yy]$ ]]; then
        echo "Installing strongSwan..."
        if command -v apt-get &> /dev/null; then
            apt-get update && apt-get install -y strongswan strongswan-pki libcharon-extra-plugins
        elif command -v yum &> /dev/null; then
            yum install -y strongswan
        else
            echo -e "${RED}✗ Could not install strongSwan automatically${NC}"
            echo "Please install strongSwan manually and run this installer again"
            exit 1
        fi
    else
        echo -e "${YELLOW}⚠ Continuing without strongSwan (configuration will not work)${NC}"
    fi
fi
echo -e "${GREEN}✓ strongSwan available${NC}"

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

# Install systemd service
echo ""
echo "Installing systemd service..."

SERVICE_FILE="/etc/systemd/system/unified-ipsec.service"
cp "$PROJECT_ROOT/services/unified-ipsec.service" "$SERVICE_FILE"

# Reload systemd
systemctl daemon-reload
echo -e "${GREEN}✓ Systemd service installed${NC}"

# Ask if user wants to enable auto-start
echo ""
echo "Do you want to enable auto-start on boot? (y/n)"
read -r response
if [[ "$response" =~ ^[Yy]$ ]]; then
    systemctl enable unified-ipsec.service
    echo -e "${GREEN}✓ Auto-start enabled${NC}"
else
    echo -e "${YELLOW}⚠ Auto-start not enabled${NC}"
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
echo "3. Or start service: sudo systemctl start unified-ipsec"
echo "4. View logs: tail -f $INSTALL_DIR/logs/ipsec.log"
echo ""
echo "Service commands:"
echo "  Start:   sudo systemctl start unified-ipsec"
echo "  Stop:    sudo systemctl stop unified-ipsec"
echo "  Status:  sudo systemctl status unified-ipsec"
echo "  Logs:    sudo journalctl -u unified-ipsec -f"
echo ""
