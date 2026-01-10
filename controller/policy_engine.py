#!/usr/bin/env python3
"""
Unified IPsec Policy Engine
Main orchestrator that loads policy and calls platform adapters
"""

import os
import sys
import platform
import yaml
import logging
import subprocess
from pathlib import Path
from datetime import datetime
from typing import Dict, Any

# Add project root to path
PROJECT_ROOT = Path(__file__).parent.parent.absolute()
sys.path.insert(0, str(PROJECT_ROOT))

from controller.validator import PolicyValidator, ValidationError


class PolicyEngine:
    """Main policy engine orchestrator"""
    
    def __init__(self, policy_path: str = None, log_path: str = None):
        """Initialize policy engine"""
        if policy_path is None:
            policy_path = PROJECT_ROOT / 'controller' / 'policy.yaml'
        if log_path is None:
            log_path = PROJECT_ROOT / 'logs' / 'ipsec.log'
        
        self.policy_path = Path(policy_path)
        self.log_path = Path(log_path)
        self.config = None
        self.detected_os = None
        
        # Setup logging
        self._setup_logging()
    
    def _setup_logging(self):
        """Configure logging to file and console"""
        # Create logs directory if needed
        self.log_path.parent.mkdir(parents=True, exist_ok=True)
        
        # Configure logging
        logging.basicConfig(
            level=logging.INFO,
            format='%(asctime)s [%(levelname)s] %(message)s',
            handlers=[
                logging.FileHandler(self.log_path),
                logging.StreamHandler(sys.stdout)
            ]
        )
        self.logger = logging.getLogger(__name__)
    
    def detect_os(self) -> str:
        """Detect operating system"""
        system = platform.system().lower()
        
        if system == 'linux':
            os_type = 'linux'
        elif system == 'windows':
            os_type = 'windows'
        elif system == 'darwin':
            os_type = 'macos'
        else:
            os_type = 'unknown'
        
        self.logger.info(f"Detected OS: {os_type}")
        self.detected_os = os_type
        return os_type
    
    def load_policy(self) -> Dict[str, Any]:
        """Load and parse policy YAML file"""
        self.logger.info(f"Loading policy from: {self.policy_path}")
        
        if not self.policy_path.exists():
            raise FileNotFoundError(f"Policy file not found: {self.policy_path}")
        
        with open(self.policy_path, 'r') as f:
            config = yaml.safe_load(f)
        
        self.logger.info("Policy loaded successfully")
        self.config = config
        return config
    
    def validate_policy(self):
        """Validate policy configuration"""
        self.logger.info("Validating policy configuration...")
        
        try:
            PolicyValidator.validate(self.config)
            self.logger.info("✓ Policy validation passed")
        except ValidationError as e:
            self.logger.error(f"✗ Policy validation failed: {e}")
            raise
    
    def call_adapter(self, os_type: str):
        """Call the appropriate OS adapter"""
        self.logger.info(f"Calling {os_type} adapter...")
        
        if os_type == 'linux':
            self._call_linux_adapter()
        elif os_type == 'windows':
            self._call_windows_adapter()
        elif os_type == 'macos':
            self._call_macos_adapter()
        else:
            raise NotImplementedError(f"No adapter for OS: {os_type}")
    
    def _call_linux_adapter(self):
        """Call Linux strongSwan adapter"""
        adapter_path = PROJECT_ROOT / 'adapters' / 'linux' / 'strongswan_adapter.py'
        
        if not adapter_path.exists():
            raise FileNotFoundError(f"Linux adapter not found: {adapter_path}")
        
        self.logger.info("Executing Linux strongSwan adapter...")
        
        # Import and call adapter
        sys.path.insert(0, str(adapter_path.parent))
        from strongswan_adapter import StrongSwanAdapter
        
        adapter = StrongSwanAdapter(self.config, self.logger)
        adapter.configure()
    
    def _call_windows_adapter(self):
        """Call Windows PowerShell adapter"""
        adapter_path = PROJECT_ROOT / 'adapters' / 'windows' / 'windows_ipsec.ps1'
        
        if not adapter_path.exists():
            raise FileNotFoundError(f"Windows adapter not found: {adapter_path}")
        
        self.logger.info("Executing Windows PowerShell adapter...")
        
        # Export policy to temp JSON for PowerShell
        import json
        temp_policy = PROJECT_ROOT / 'logs' / 'policy_temp.json'
        with open(temp_policy, 'w') as f:
            json.dump(self.config, f, indent=2)
        
        # Call PowerShell script
        try:
            result = subprocess.run(
                ['powershell.exe', '-ExecutionPolicy', 'Bypass', '-File', 
                 str(adapter_path), '-PolicyFile', str(temp_policy)],
                capture_output=True,
                text=True,
                check=True
            )
            self.logger.info(f"Windows adapter output: {result.stdout}")
        except subprocess.CalledProcessError as e:
            self.logger.error(f"Windows adapter failed: {e.stderr}")
            raise
        finally:
            # Cleanup temp file
            if temp_policy.exists():
                temp_policy.unlink()
    
    def _call_macos_adapter(self):
        """Call macOS shell adapter"""
        adapter_path = PROJECT_ROOT / 'adapters' / 'macos' / 'macos_ipsec.sh'
        
        if not adapter_path.exists():
            raise FileNotFoundError(f"macOS adapter not found: {adapter_path}")
        
        self.logger.info("Executing macOS adapter (prototype stub)...")
        
        # Export policy to temp JSON for shell script
        import json
        temp_policy = PROJECT_ROOT / 'logs' / 'policy_temp.json'
        with open(temp_policy, 'w') as f:
            json.dump(self.config, f, indent=2)
        
        # Call shell script
        try:
            result = subprocess.run(
                ['bash', str(adapter_path), str(temp_policy)],
                capture_output=True,
                text=True,
                check=True
            )
            self.logger.info(f"macOS adapter output: {result.stdout}")
        except subprocess.CalledProcessError as e:
            self.logger.error(f"macOS adapter failed: {e.stderr}")
            raise
        finally:
            # Cleanup temp file
            if temp_policy.exists():
                temp_policy.unlink()
    
    def run(self):
        """Main execution flow"""
        try:
            self.logger.info("=" * 60)
            self.logger.info("UNIFIED IPSEC POLICY ENGINE STARTING")
            self.logger.info("=" * 60)
            
            # Detect OS
            os_type = self.detect_os()
            
            # Load policy
            self.load_policy()
            
            # Validate policy
            self.validate_policy()
            
            # Call adapter
            self.call_adapter(os_type)
            
            self.logger.info("=" * 60)
            self.logger.info("✓ POLICY ENGINE COMPLETED SUCCESSFULLY")
            self.logger.info("=" * 60)
            
            return 0
            
        except Exception as e:
            self.logger.error("=" * 60)
            self.logger.error(f"✗ POLICY ENGINE FAILED: {e}")
            self.logger.error("=" * 60)
            return 1


def main():
    """Entry point"""
    # Allow custom policy path from command line
    policy_path = sys.argv[1] if len(sys.argv) > 1 else None
    
    engine = PolicyEngine(policy_path=policy_path)
    exit_code = engine.run()
    sys.exit(exit_code)


if __name__ == '__main__':
    main()
