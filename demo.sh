#!/bin/bash
# Quick Start Demo Script
# Demonstrates the unified IPsec solution

set -e

echo "============================================"
echo "Unified IPsec - Quick Start Demo"
echo "============================================"
echo ""

# Check if in project root
if [ ! -f "controller/policy.yaml" ]; then
    echo "Error: Please run this script from the project root directory"
    exit 1
fi

# Check for PyYAML
echo "Checking dependencies..."
if ! python3 -c "import yaml" 2>/dev/null; then
    echo "⚠ PyYAML not installed. Installing..."
    pip3 install pyyaml --user 2>/dev/null || pip3 install pyyaml 2>/dev/null || {
        echo ""
        echo "Please install PyYAML manually:"
        echo "  pip3 install pyyaml"
        echo "  or: pip3 install -r requirements.txt"
        echo ""
        exit 1
    }
    echo "✓ PyYAML installed"
fi
echo "✓ All dependencies present"
echo ""

# Step 1: Validate policy
echo "Step 1: Validating policy configuration..."
python3 controller/validator.py
echo ""

# Step 2: Show policy
echo "Step 2: Current policy configuration:"
echo "---"
cat controller/policy.yaml
echo "---"
echo ""

# Step 3: Explain what would happen
echo "Step 3: What happens when you run the policy engine:"
echo ""
echo "  1. Detects your operating system"
echo "  2. Loads and validates policy.yaml"
echo "  3. Calls the appropriate adapter:"
echo ""
echo "     Linux   -> adapters/linux/strongswan_adapter.py"
echo "     Windows -> adapters/windows/windows_ipsec.ps1"
echo "     macOS   -> adapters/macos/macos_ipsec.sh"
echo ""
echo "  4. Generates platform-specific configurations"
echo "  5. Applies the configuration"
echo "  6. Logs everything to logs/ipsec.log"
echo ""

# Step 4: Check privileges
echo "Step 4: Checking execution environment..."
if [ "$EUID" -eq 0 ]; then
    echo "  ✓ Running as root - can modify system configurations"
    CAN_RUN=true
else
    echo "  ⚠ Not running as root - will preview only (no system changes)"
    CAN_RUN=false
fi
echo ""

# Step 5: Run policy engine
echo "Step 5: Running policy engine..."
echo ""

if [ "$CAN_RUN" = true ]; then
    python3 controller/policy_engine.py
else
    echo "Preview mode (no system changes will be made):"
    echo ""
    python3 controller/policy_engine.py 2>&1 || true
fi

echo ""
echo "============================================"
echo "Demo Complete!"
echo "============================================"
echo ""
echo "Next steps:"
echo "  1. Review the logs: tail -f logs/ipsec.log"
echo "  2. Customize policy: edit controller/policy.yaml"
echo "  3. Install system-wide: sudo ./installer/install_linux.sh"
echo "  4. Read full docs: less README.md"
echo ""
