# Mac Development Machine Setup - Ansible Version (Archived)

> **⚠️ IMPORTANT NOTE**: This Ansible-based setup is **archived and no longer maintained**.
>
> **Please use the shell script version in [`../mac-dev-machine/`](../mac-dev-machine/) instead.**
>
> This directory is kept for reference and potential future use.

## Why Was This Archived?

The Ansible approach encountered a fundamental architectural problem:

- .NET SDK `.pkg` installer requires root privileges
- Homebrew refuses to run as root (security policy)
- Ansible's `become: yes` runs Homebrew as root, causing conflicts
- This created an unsolvable catch-22 with the Ansible approach

The project was converted to a simple shell script approach (similar to the Windows PowerShell setup in this repository). See [CHANGELOG.md](../mac-dev-machine/CHANGELOG.md) for full details.

## What's in This Directory

This directory contains the original Ansible-based setup:

- `bootstrap.sh` - Bootstrap script that installs Ansible and runs the playbook
- `playbook.yml` - Main Ansible playbook
- `inventory.yml` - Ansible inventory configuration
- `requirements.yml` - Ansible Galaxy requirements
- `roles/` - Ansible role definitions
- `group_vars/` - Ansible variable definitions
- `files/` - Static files for configuration
- `docs/` - Original Ansible-based documentation

## If You Want to Use This Anyway

While not recommended, you can still run this Ansible setup:

```bash
cd ansible-dev-setup
./bootstrap.sh
```

**Known Issues**:
- .NET SDK installation may fail due to privilege conflicts
- Homebrew may show warnings about running as root
- Some packages may not install correctly

## Recommended Alternative

Use the **shell script version** in `mac-dev-machine/`:

```bash
cd ../mac-dev-machine
cp config.example.sh config.sh
# Edit config.sh with your settings
./setup.sh
```

**Benefits**:
- ✅ No Ansible installation required
- ✅ Simpler and faster
- ✅ Better error handling
- ✅ No privilege conflicts
- ✅ Actively maintained

## Documentation

For historical reference, the original Ansible documentation is available in:

- [docs/](docs/) - Full documentation directory
- [docs/OVERVIEW.md](docs/OVERVIEW.md) - Architecture and execution flow
- [docs/CUSTOMIZATION.md](docs/CUSTOMIZATION.md) - How to customize
- [docs/TROUBLESHOOTING.md](docs/TROUBLESHOOTING.md) - Common issues

## Future Plans

This Ansible setup may be revisited in the future if:
- A solution is found for the Homebrew/sudo conflict
- Ansible support is needed for cross-platform consistency
- Multi-machine orchestration becomes necessary

For now, the shell script approach is the recommended and supported method.

---

**Last Updated**: November 2025
**Status**: Archived / Reference Only
**Maintained**: No (use shell script version instead)
