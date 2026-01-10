# ============================================================================
# POLICY EXAMPLES: Different IPsec Modes and Protocols
# ============================================================================
# This file shows various combinations of:
# - IPsec MODES: tunnel (site-to-site) vs transport (host-to-host)
# - IPsec PROTOCOLS: esp (encryption), ah (auth-only), esp-ah (combined)
#
# Use these examples to understand the differences and create your own policies.
# ============================================================================

# ============================================================================
# EXAMPLE 1: SIMPLE ESP TUNNEL MODE (MOST COMMON)
# ============================================================================
# Use case: Protect subnets between two sites
# Mode: tunnel - entire IP packets are encrypted and authenticated
# Protocol: esp - provides encryption (AES256) and integrity (SHA256)
#
global:
  ike_version: ikev2
  auth_method: psk
  psk: "example_shared_key_1"
  encryption: aes256
  integrity: sha256
  dh_group: 14
  auto_start: true

tunnels:
  - name: branch_office_tunnel
    mode: tunnel                  # Tunnel mode: encapsulate entire packet
    protocol: esp                 # ESP: encryption + integrity
    local_subnet: 192.168.1.0/24  # Head office subnet
    remote_subnet: 10.0.0.0/24    # Branch office subnet
    peer_ip: 203.0.113.100        # Branch IPsec gateway
    enabled: true


# ============================================================================
# EXAMPLE 2: HOST-TO-HOST TRANSPORT MODE
# ============================================================================
# Use case: Protect direct communication between two specific hosts
# Mode: transport - only the payload is encrypted, IP header remains visible
# Protocol: esp - encryption and integrity
#
# NOTE: Uncomment and replace the above tunnels section to use this example
#
# tunnels:
#   - name: database_replication
#     mode: transport             # Transport mode: no extra IP header
#     protocol: esp               # ESP: encryption + integrity
#     peer_ip: 192.168.1.50       # Direct host-to-host communication
#     enabled: true


# ============================================================================
# EXAMPLE 3: AUTHENTICATION HEADER MODE (AH ONLY)
# ============================================================================
# Use case: When you need integrity/authentication but not encryption
#           (often for regulatory compliance or non-sensitive data)
#
# WARNING: AH provides NO ENCRYPTION, only authentication.
# Data remains readable, but tampering is detected.
#
# NOTE: Uncomment and replace the above tunnels section to use this example
#
# tunnels:
#   - name: audit_tunnel
#     mode: tunnel
#     protocol: ah                # AH: authentication/integrity only (NO encryption)
#     local_subnet: 10.0.0.0/24
#     remote_subnet: 192.168.1.0/24
#     peer_ip: 203.0.113.100
#     enabled: true


# ============================================================================
# EXAMPLE 4: COMBINED ESP+AH MODE (MAXIMUM SECURITY)
# ============================================================================
# Use case: When you need the strongest security
# Mode: tunnel
# Protocol: esp-ah - provides encryption + dual authentication
#
# NOTE: Slight performance overhead due to dual processing.
# Most deployments use ESP alone, which is sufficient.
#
# NOTE: Uncomment and replace the above tunnels section to use this example
#
# tunnels:
#   - name: critical_tunnel
#     mode: tunnel
#     protocol: esp-ah            # ESP+AH: encryption + dual authentication
#     local_subnet: 10.0.0.0/24
#     remote_subnet: 192.168.1.0/24
#     peer_ip: 203.0.113.100
#     enabled: true


# ============================================================================
# EXAMPLE 5: MIXED TUNNELS (MULTIPLE MODES IN ONE POLICY)
# ============================================================================
# Use case: Complex network with different security requirements for different paths
#
# NOTE: Uncomment and replace the above tunnels section to use this example
#
# tunnels:
#   # Site-to-site tunnel with encryption
#   - name: vpn_gateway_tunnel
#     mode: tunnel
#     protocol: esp
#     local_subnet: 10.0.0.0/24
#     remote_subnet: 192.168.1.0/24
#     peer_ip: 203.0.113.100
#     enabled: true
#
#   # Direct host-to-host for database
#   - name: db_replication_transport
#     mode: transport
#     protocol: esp
#     peer_ip: 192.168.50.100
#     enabled: true
#
#   # Authentication-only tunnel for audit logs
#   - name: audit_tunnel
#     mode: tunnel
#     protocol: ah
#     local_subnet: 10.1.0.0/24
#     remote_subnet: 192.168.2.0/24
#     peer_ip: 203.0.113.101
#     enabled: true


# ============================================================================
# IPSEC MODES AND PROTOCOLS REFERENCE
# ============================================================================
#
# IPSEC MODES:
# ============
#
# 1. TUNNEL MODE
#    - Used for: Site-to-site VPN, protecting subnets
#    - Behavior: Encapsulates entire IP packet with new IP header
#    - Where it fits: Between IPsec gateways/routers
#    - Visibility: Internal IP addresses are hidden from outside
#    
#    Original packet:  [IP1][TCP][DATA]
#    After ESP Tunnel: [IP_GATEWAY][ESP][IP1][TCP][DATA]
#                      ^^^^^^^^^^ New IP header added
#
#
# 2. TRANSPORT MODE
#    - Used for: Host-to-host VPN, direct communication
#    - Behavior: Encrypts only the payload, original IP header unchanged
#    - Where it fits: Between hosts directly
#    - Visibility: IP header remains visible, only payload is encrypted
#    
#    Original packet:  [IP1][TCP][DATA]
#    After ESP Transport: [IP1][ESP][TCP][DATA]]
#                         ^^^^ Same IP header, only payload encrypted


# IPSEC PROTOCOLS:
# ================
#
# 1. ESP (Encapsulating Security Payload)
#    - Provides: Confidentiality (encryption) + Integrity
#    - Use when: You need both encryption and integrity checking
#    - Most common choice for VPN deployments
#    - Algorithms: Encryption (AES-256), Integrity (SHA-256)
#
#
# 2. AH (Authentication Header)
#    - Provides: Integrity + Authentication only
#    - Does NOT provide: Encryption (data is readable!)
#    - Use when: You need to prove authenticity, not hide content
#    - Example: Audit logs, compliance scenarios
#    - WARNING: Use ESP instead unless you have specific AH requirement
#
#
# 3. ESP+AH (Combined)
#    - Provides: Encryption (ESP) + Dual Authentication (ESP+AH)
#    - Maximum security level
#    - Slight performance overhead
#    - Use when: Highest security requirement
#    - Most deployments use ESP alone (sufficient and faster)


# ============================================================================
# TYPICAL DEPLOYMENT RECOMMENDATION
# ============================================================================
#
# For most use cases, use:
#   - MODE: tunnel
#   - PROTOCOL: esp
#   - ENCRYPTION: aes256
#   - INTEGRITY: sha256
#
# This combination provides:
#   ✓ Strong encryption (AES-256)
#   ✓ Strong integrity (SHA-256)
#   ✓ Good performance
#   ✓ Industry standard
#
# ============================================================================
