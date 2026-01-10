# Contributing to Unified IPsec

We appreciate contributions! This document explains our development process.

## Code Style

- **Python**: Follow [PEP 8](https://www.python.org/dev/peps/pep-0008/)
- **Shell**: Follow [ShellCheck](https://www.shellcheck.net/) standards
- **PowerShell**: Use proper formatting and error handling

## Development Setup

```bash
# Clone the repository
git clone https://github.com/yourusername/unified-ipsec.git
cd unified-ipsec

# Create virtual environment
python3 -m venv venv
source venv/bin/activate

# Install dependencies
pip install -r requirements.txt

# Test the demo
./demo.sh
```

## Testing

Before submitting:

1. **Validate policy syntax:**
   ```bash
   python3 controller/validator.py
   ```

2. **Run demo (non-destructive):**
   ```bash
   ./demo.sh
   ```

3. **Test on target OS:**
   - Linux: Use Docker or VM
   - Windows: Test in PowerShell ISE
   - macOS: Test on actual macOS system

## Commit Guidelines

- Use clear, descriptive commit messages
- Reference issues when applicable: `Fixes #123`
- One feature per commit

## Pull Request Process

1. Fork the repository
2. Create a feature branch: `git checkout -b feature/description`
3. Make your changes
4. Test thoroughly
5. Submit a pull request with detailed description
6. Address review feedback

## Reporting Bugs

When reporting issues, include:
- Operating system and version
- Python version
- Error logs (from `logs/ipsec.log`)
- Steps to reproduce
- Expected vs actual behavior

## Feature Requests

Suggestions for improvement are welcome! Please describe:
- Use case
- Proposed solution
- Alternatives considered
