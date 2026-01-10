#!/usr/bin/env python3
"""
Policy Validator
Validates unified IPsec policy configuration
"""

import sys
from typing import Dict, List, Any


class ValidationError(Exception):
    """Custom exception for validation errors"""
    pass


class PolicyValidator:
    """Validates IPsec policy configuration"""
    
    VALID_IKE_VERSIONS = ['ikev1', 'ikev2']
    VALID_AUTH_METHODS = ['psk', 'cert', 'rsa']
    VALID_ENCRYPTIONS = ['aes128', 'aes192', 'aes256', '3des']
    VALID_INTEGRITIES = ['sha1', 'sha256', 'sha384', 'sha512', 'md5']
    VALID_DH_GROUPS = [2, 5, 14, 15, 16, 17, 18, 19, 20, 21]
    VALID_MODES = ['tunnel', 'transport']
    VALID_PROTOCOLS = ['esp', 'ah']
    
    @staticmethod
    def validate_global(config: Dict[str, Any]) -> None:
        """Validate global configuration"""
        if 'global' not in config:
            raise ValidationError("Missing 'global' section in policy")
        
        global_cfg = config['global']
        
        # IKE version
        ike_version = global_cfg.get('ike_version', '').lower()
        if ike_version not in PolicyValidator.VALID_IKE_VERSIONS:
            raise ValidationError(
                f"Invalid IKE version '{ike_version}'. "
                f"Must be one of: {PolicyValidator.VALID_IKE_VERSIONS}"
            )
        
        # Auth method
        auth_method = global_cfg.get('auth_method', '').lower()
        if auth_method not in PolicyValidator.VALID_AUTH_METHODS:
            raise ValidationError(
                f"Invalid auth method '{auth_method}'. "
                f"Must be one of: {PolicyValidator.VALID_AUTH_METHODS}"
            )
        
        # PSK required if auth_method is psk
        if auth_method == 'psk' and not global_cfg.get('psk'):
            raise ValidationError("PSK authentication requires 'psk' field")
        
        # Encryption
        encryption = global_cfg.get('encryption', '').lower()
        if encryption not in PolicyValidator.VALID_ENCRYPTIONS:
            raise ValidationError(
                f"Invalid encryption '{encryption}'. "
                f"Must be one of: {PolicyValidator.VALID_ENCRYPTIONS}"
            )
        
        # Integrity
        integrity = global_cfg.get('integrity', '').lower()
        if integrity not in PolicyValidator.VALID_INTEGRITIES:
            raise ValidationError(
                f"Invalid integrity '{integrity}'. "
                f"Must be one of: {PolicyValidator.VALID_INTEGRITIES}"
            )
        
        # DH group
        dh_group = global_cfg.get('dh_group')
        if dh_group not in PolicyValidator.VALID_DH_GROUPS:
            raise ValidationError(
                f"Invalid DH group '{dh_group}'. "
                f"Must be one of: {PolicyValidator.VALID_DH_GROUPS}"
            )
    
    @staticmethod
    def validate_tunnel(tunnel: Dict[str, Any], index: int) -> None:
        """Validate a single tunnel configuration"""
        # Name
        if 'name' not in tunnel:
            raise ValidationError(f"Tunnel {index}: Missing 'name' field")
        
        name = tunnel['name']
        
        # Mode
        mode = tunnel.get('mode', '').lower()
        if mode not in PolicyValidator.VALID_MODES:
            raise ValidationError(
                f"Tunnel '{name}': Invalid mode '{mode}'. "
                f"Must be one of: {PolicyValidator.VALID_MODES}"
            )
        
        # Protocol
        protocol = tunnel.get('protocol', '').lower()
        if protocol not in PolicyValidator.VALID_PROTOCOLS:
            raise ValidationError(
                f"Tunnel '{name}': Invalid protocol '{protocol}'. "
                f"Must be one of: {PolicyValidator.VALID_PROTOCOLS}"
            )
        
        # Peer IP (required)
        if 'peer_ip' not in tunnel:
            raise ValidationError(f"Tunnel '{name}': Missing 'peer_ip' field")
        
        # Tunnel mode requires subnets
        if mode == 'tunnel':
            if 'local_subnet' not in tunnel:
                raise ValidationError(
                    f"Tunnel '{name}': Tunnel mode requires 'local_subnet'"
                )
            if 'remote_subnet' not in tunnel:
                raise ValidationError(
                    f"Tunnel '{name}': Tunnel mode requires 'remote_subnet'"
                )
    
    @staticmethod
    def validate_tunnels(config: Dict[str, Any]) -> None:
        """Validate all tunnel configurations"""
        if 'tunnels' not in config:
            raise ValidationError("Missing 'tunnels' section in policy")
        
        tunnels = config['tunnels']
        if not isinstance(tunnels, list):
            raise ValidationError("'tunnels' must be a list")
        
        if len(tunnels) == 0:
            raise ValidationError("At least one tunnel must be defined")
        
        for idx, tunnel in enumerate(tunnels):
            PolicyValidator.validate_tunnel(tunnel, idx)
    
    @staticmethod
    def validate(config: Dict[str, Any]) -> None:
        """Validate complete policy configuration"""
        PolicyValidator.validate_global(config)
        PolicyValidator.validate_tunnels(config)


def main():
    """Test validator with sample config"""
    test_config = {
        'global': {
            'ike_version': 'ikev2',
            'auth_method': 'psk',
            'psk': 'test_key',
            'encryption': 'aes256',
            'integrity': 'sha256',
            'dh_group': 14
        },
        'tunnels': [
            {
                'name': 'test_tunnel',
                'mode': 'tunnel',
                'protocol': 'esp',
                'local_subnet': '10.0.0.0/24',
                'remote_subnet': '192.168.1.0/24',
                'peer_ip': '203.0.113.10'
            }
        ]
    }
    
    try:
        PolicyValidator.validate(test_config)
        print("✓ Validation passed")
    except ValidationError as e:
        print(f"✗ Validation failed: {e}")
        sys.exit(1)


if __name__ == '__main__':
    main()
