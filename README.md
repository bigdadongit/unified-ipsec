Unified Cross-Platform IPsec Solution




A unified, policy-driven IPsec solution that enables automatic network traffic encryption across Linux, Windows, macOS, and BOSS OS using a single centralized configuration.

Overview

Enterprise environments run multiple operating systems, each with different IPsec configuration mechanisms. This project eliminates fragmentation by providing a single policy file (policy.yaml) that is validated and deployed consistently across platforms.

Key Features

Single centralized policy for all operating systems

Automatic IPsec tunnel deployment with auto-start on boot

Cross-platform support: Linux (strongSwan), Windows (PowerShell), macOS, BOSS OS

Multiple IPsec modes: Tunnel, Transport

Protocol support: ESP, AH, ESP+AH

IKEv1 & IKEv2 support

Multi-tunnel configuration (multiple peers and subnets)

Built-in validation and logging

Architecture (High Level)
policy.yaml
     ↓
Policy Engine (validation + orchestration)
     ↓
OS Detection
     ↓
Linux | Windows | macOS | BOSS OS Adapters

Core Components

controller/policy.yaml – Unified IPsec policy definition

controller/policy_engine.py – Policy loader, validator, and orchestrator

controller/validator.py – Configuration validation

adapters/ – OS-specific IPsec implementations

installer/ – Automated installation scripts

services/ – Auto-start service definitions

Supported Capabilities
Category	Support
IPsec Modes	Tunnel, Transport
Protocols	ESP, AH, ESP+AH
Encryption	AES-128/192/256, 3DES
Integrity	SHA-1, SHA-256, SHA-384, SHA-512
Key Exchange	IKEv1, IKEv2
Authentication	PSK (implemented), Certificates (structure)
Platforms	Linux, Windows, macOS, BOSS OS
Quick Start

Install – Run the installer for your OS

Configure – Edit controller/policy.yaml

Validate – python3 controller/validator.py

Deploy – python3 controller/policy_engine.py

Verify – Check service status and logs

Status & Notes

Hackathon prototype 

Primary focus: Linux (strongSwan)

Windows support implemented via PowerShell

macOS adapter currently a stub

Certificate-based authentication planned

License

MIT License
