# Sample Configuration Files

This directory contains sample configuration files that can be customized and deployed to your home directory.

## Available Files

### .gitignore_global
A comprehensive global gitignore file for macOS development that excludes:
- macOS system files (.DS_Store, etc.)
- IDE configuration files
- Node.js dependencies
- .NET build artifacts
- Python bytecode and virtual environments
- Environment variable files

To use this file:
```bash
cp files/.gitignore_global ~/.gitignore_global
git config --global core.excludesfile ~/.gitignore_global
```

### .editorconfig
EditorConfig configuration for consistent coding styles across editors:
- UTF-8 encoding
- LF line endings
- Consistent indentation (2 spaces for JS/TS, 4 for C#/Python)
- Trailing whitespace handling

Most modern editors (VS Code, etc.) automatically detect and use .editorconfig files in your project root.

## Customization

These files are templates. Feel free to:
1. Copy them to your home directory or project roots
2. Modify them to match your preferences
3. Add additional configuration files as needed

## Integration with Ansible

You can modify the dotfiles role to automatically deploy these files:
1. Edit `roles/dotfiles/tasks/main.yml`
2. Add copy tasks for the files you want to deploy
3. Re-run the playbook to apply changes
