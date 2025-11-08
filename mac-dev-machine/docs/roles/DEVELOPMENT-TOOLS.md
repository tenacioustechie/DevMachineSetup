# Development Tools Role Documentation

## Purpose

The Development Tools role configures programming language runtimes and development tools. It sets up Node.js, .NET SDK, Python, and related tools to match the versions and configuration from your Windows development setup.

## What Gets Installed

### Node.js Environment
- **fnm** (Fast Node Manager): Node.js version manager
- **Node.js**: Specific version (default: 20.15.0)
- **Global npm packages**: Angular CLI, TypeScript, Yarn, PNPM, etc.

### .NET Environment
- **.NET SDK**: Version 8.0 (matching Windows setup)
- **NuGet**: Package manager (included with SDK)

### Python Environment
- **Python 3.11**: Interpreter
- **pip**: Package manager
- **pipenv**: Virtual environment manager
- **virtualenv**: Alternative virtual environment tool
- **black**: Code formatter
- **pylint**: Linter

### Additional Tools
- **Git LFS**: Large file support for Git
- **Docker**: Container runtime verification

## Task-by-Task Breakdown

### 1. Configure fnm (Fast Node Manager)

#### Why fnm instead of nvm?

- **Faster**: Written in Rust, significantly faster than nvm
- **Cross-platform**: Works on macOS, Linux, Windows
- **Simple**: Single binary, no shell script loading
- **Automatic switching**: Uses `.node-version` or `.nvmrc` files

#### What happens:

**Step 1: Check if fnm is installed**
```bash
which fnm
```
**Purpose**: Verify fnm is available (installed by Homebrew role)

---

**Step 2: Add fnm to shell configuration**

**Command**: Adds this line to `~/.zshrc`:
```bash
eval "$(fnm env --use-on-cd)"
```

**What this does**:
- Initializes fnm in your shell
- Enables automatic Node version switching when you `cd` into a project
- Sets up `PATH` to include Node binaries

**Ansible Task**:
```yaml
- name: Add fnm to shell configuration
  lineinfile:
    path: "{{ user_home }}/.zshrc"
    line: 'eval "$(fnm env --use-on-cd)"'
    create: yes
    state: present
```

**Idempotent**: Yes - only adds if not present

---

**Step 3: Install Node.js via fnm**

**Commands**:
```bash
eval "$(fnm env --use-on-cd)"
fnm install 20.15.0
fnm use 20.15.0
fnm default 20.15.0
```

**What each command does**:
- `fnm install 20.15.0`: Downloads and installs Node.js 20.15.0
- `fnm use 20.15.0`: Activates this version for current shell
- `fnm default 20.15.0`: Sets as default for new shells

**Installation location**: `~/.local/share/fnm/node-versions/v20.15.0/`

**Ansible Task**:
```yaml
- name: Install Node.js via fnm
  shell: |
    eval "$(fnm env --use-on-cd)"
    fnm install {{ node_version }}
    fnm use {{ node_version }}
    fnm default {{ node_version }}
  args:
    executable: /bin/zsh
    creates: "{{ user_home }}/.local/share/fnm/node-versions/v{{ node_version }}"
```

**Idempotent**: Yes - `creates` ensures it only runs if Node version not present

---

**Step 4: Verify Node.js installation**

**Command**:
```bash
node --version
```

**Expected output**: `v20.15.0`

---

### 2. Install Global npm Packages

**What it does**: Installs Node.js tools globally

**Default packages**:

| Package | Purpose | Command Added |
|---------|---------|---------------|
| `@angular/cli` | Angular framework CLI | `ng` |
| `typescript` | TypeScript compiler | `tsc` |
| `ts-node` | Run TypeScript directly | `ts-node` |
| `yarn` | Alternative package manager | `yarn` |
| `pnpm` | Fast package manager | `pnpm` |
| `npm-check-updates` | Update package.json | `ncu` |

**Command**:
```bash
npm install -g @angular/cli
npm install -g typescript
# ... for each package
```

**Ansible Task**:
```yaml
- name: Install global npm packages
  shell: |
    eval "$(fnm env --use-on-cd)"
    npm install -g {{ item }}
  loop: "{{ nodejs_global_packages }}"
```

**Installation location**: `~/.local/share/fnm/node-versions/v20.15.0/bin/`

**Idempotent**: Mostly - npm checks if package is installed, reports "up to date"

---

### 3. Install .NET SDK

#### Why .NET SDK 8.0?

Matches your Windows setup for cross-platform development.

**What happens**:

**Step 1: Add .NET tap**
```bash
brew tap isen-ng/dotnet-sdk-versions
```

**Purpose**: This tap provides specific .NET SDK versions

---

**Step 2: Check for existing .NET installation**
```bash
dotnet --version
```

---

**Step 3: Install .NET SDK via Homebrew**
```bash
brew install --cask dotnet-sdk8.0
```

**What gets installed**:
- .NET SDK 8.0
- .NET Runtime
- ASP.NET Core Runtime
- NuGet package manager

**Installation location**: `/usr/local/share/dotnet/`

**Ansible Task**:
```yaml
- name: Install .NET SDK via Homebrew
  homebrew_cask:
    name: "dotnet-sdk{{ dotnet_sdk_version }}"
    state: present
  when: dotnet_check.rc != 0 or dotnet_sdk_version not in dotnet_check.stdout
```

**Idempotent**: Yes - only installs if version not found

---

**Step 4: Verify .NET installation**
```bash
dotnet --version
```

**Expected output**: `8.0.xxx`

**Common .NET commands**:
```bash
dotnet new console -n MyApp    # Create new console app
dotnet build                   # Build project
dotnet run                     # Run project
dotnet test                    # Run tests
dotnet publish                 # Publish for deployment
```

---

### 4. Configure Python

**What happens**:

**Step 1: Set Python 3 as default python**

**Command**:
```bash
ln -s /opt/homebrew/bin/python3 /opt/homebrew/bin/python
```

**Purpose**: Allows you to use `python` instead of `python3`

**Note**: This step may fail if link already exists (safe to ignore)

---

**Step 2: Install pip packages**

**Packages installed**:

| Package | Purpose |
|---------|---------|
| `pipenv` | Virtual environment and dependency manager |
| `virtualenv` | Create isolated Python environments |
| `black` | Code formatter (PEP 8 compliant) |
| `pylint` | Linting and code analysis |

**Command**:
```bash
pip3 install pipenv virtualenv black pylint
```

**Ansible Task**:
```yaml
- name: Install pip packages
  pip:
    name:
      - pipenv
      - virtualenv
      - black
      - pylint
    executable: pip3
    state: present
```

**Installation location**: `~/.local/lib/python3.11/site-packages/`

---

**Step 3: Verify Python installation**
```bash
python3 --version
```

**Expected output**: `Python 3.11.x`

**Common Python commands**:
```bash
python3 script.py              # Run Python script
pip3 install package-name      # Install package
pipenv install                 # Install project dependencies
black file.py                  # Format Python file
pylint file.py                 # Lint Python file
```

---

### 5. Configure Docker

**What it does**: Verifies Docker Desktop is installed and running

**Command**:
```bash
docker info
```

**Expected output**: Docker server information

**If not running**: Displays message to start Docker Desktop manually

**Note**: Docker Desktop must be started manually from `/Applications/Docker.app`

**Ansible Task**:
```yaml
- name: Check if Docker is running
  command: docker info
  register: docker_check
  changed_when: false
  failed_when: false
```

**Why manual start**: Docker Desktop requires GUI and user agreement to terms

---

### 6. Configure Git LFS

**What it does**: Initializes Git Large File Storage

**Command**:
```bash
git lfs install
```

**Purpose**:
- Registers Git LFS hooks
- Enables tracking of large files in Git repos
- Required for repos that use LFS

**Ansible Task**:
```yaml
- name: Initialize Git LFS
  command: git lfs install
  register: git_lfs_init
  changed_when: "'Updated' in git_lfs_init.stdout"
```

**Idempotent**: Yes - running multiple times is safe

---

### 7. Display Summary

**What it does**: Shows installed versions

**Example output**:
```
Development Tools Installation Complete
Node.js: v20.15.0
.NET SDK: 8.0.100
Python: Python 3.11.6
Docker: Running
```

## Configuration

### Changing Node.js Version

Edit `group_vars/all.yml`:

```yaml
node_version: "18.17.0"  # Change to desired version
```

Available versions: https://nodejs.org/en/download/releases/

### Adding npm Global Packages

Edit `group_vars/all.yml`:

```yaml
nodejs_global_packages:
  - "@angular/cli"
  - "typescript"
  - "eslint"        # Add this
  - "prettier"      # Add this
```

### Changing .NET Version

Edit `group_vars/all.yml`:

```yaml
dotnet_sdk_version: "7.0"  # Change to desired version
```

Available versions: Check `brew search dotnet`

### Adding Python Packages

Not currently configurable via variables. To add:

1. Edit `roles/development-tools/tasks/main.yml`
2. Add package to pip list:
```yaml
- name: Install pip packages
  pip:
    name:
      - pipenv
      - virtualenv
      - black
      - pylint
      - requests  # Add this
```

Or install manually:
```bash
pip3 install package-name
```

## File Locations

### Node.js
```
~/.local/share/fnm/
├── node-versions/
│   └── v20.15.0/
│       ├── bin/
│       │   ├── node
│       │   ├── npm
│       │   └── npx
│       └── lib/node_modules/
└── aliases/
    └── default -> ../node-versions/v20.15.0
```

### .NET
```
/usr/local/share/dotnet/
├── dotnet           # CLI executable
├── sdk/
│   └── 8.0.100/
└── shared/
    ├── Microsoft.NETCore.App/
    └── Microsoft.AspNetCore.App/
```

### Python
```
/opt/homebrew/bin/
├── python3         # Python interpreter
└── pip3            # Package manager

~/.local/lib/python3.11/
└── site-packages/  # User-installed packages
```

## Version Management

### Using Multiple Node.js Versions

**Install additional version**:
```bash
fnm install 18.17.0
```

**Switch versions**:
```bash
fnm use 18.17.0
```

**List installed versions**:
```bash
fnm list
```

**Per-project Node version**:

Create `.node-version` in project root:
```
18.17.0
```

fnm automatically switches when you `cd` into the directory.

### Using Multiple .NET Versions

.NET SDKs can coexist:

**List installed SDKs**:
```bash
dotnet --list-sdks
```

**Use specific version in project**:

Create `global.json`:
```json
{
  "sdk": {
    "version": "8.0.100"
  }
}
```

## Common Issues

### Issue: fnm command not found

**Cause**: Shell not reloaded after installation

**Solution**:
```bash
source ~/.zshrc
# Or restart terminal
```

---

### Issue: node command not found

**Cause**: fnm not initialized

**Solution**:
```bash
eval "$(fnm env --use-on-cd)"
node --version
```

Or restart terminal to load `.zshrc`.

---

### Issue: .NET SDK not found after installation

**Cause**: SDK installed but not in PATH

**Solution**:
```bash
export PATH="/usr/local/share/dotnet:$PATH"
```

Add to `.zshrc`:
```bash
export PATH="/usr/local/share/dotnet:$PATH"
```

---

### Issue: pip install permission denied

**Cause**: Trying to install to system Python

**Solution**: Use user install:
```bash
pip3 install --user package-name
```

Or use virtual environment:
```bash
python3 -m venv venv
source venv/bin/activate
pip install package-name
```

---

### Issue: Docker not running

**Cause**: Docker Desktop not started

**Solution**:
1. Open Docker Desktop from Applications
2. Wait for whale icon in menu bar to stop animating
3. Retry: `docker info`

## Performance Notes

**Installation time**:
- Node.js: 2-3 minutes
- .NET SDK: 3-5 minutes
- Python packages: 1-2 minutes
- Total: ~10 minutes

**Disk space**:
- Node.js: ~200MB per version
- .NET SDK: ~500MB
- Python packages: ~100MB

## Useful Commands

### Node.js / fnm

```bash
# List available Node versions
fnm ls-remote

# Install specific version
fnm install 18.17.0

# Use version
fnm use 18.17.0

# Set default
fnm default 18.17.0

# Uninstall version
fnm uninstall 18.17.0

# Check current version
node --version

# Update npm globally
npm install -g npm@latest

# List global packages
npm list -g --depth=0
```

### .NET

```bash
# Check version
dotnet --version

# List SDKs
dotnet --list-sdks

# List runtimes
dotnet --list-runtimes

# Create new project
dotnet new console -n MyApp

# Restore packages
dotnet restore

# Build
dotnet build

# Run
dotnet run

# Test
dotnet test

# Add package
dotnet add package PackageName
```

### Python

```bash
# Check version
python3 --version

# Install package
pip3 install package-name

# Install from requirements.txt
pip3 install -r requirements.txt

# List installed packages
pip3 list

# Show package info
pip3 show package-name

# Create virtual environment
python3 -m venv venv

# Activate virtual environment
source venv/bin/activate

# Deactivate
deactivate

# Format code with black
black file.py

# Lint with pylint
pylint file.py
```

## Tags

Run only development tools tasks:
```bash
ansible-playbook playbook.yml --tags "development"
```

Available tags:
- `development`: All development tools
- `node`, `fnm`: Node.js setup
- `dotnet`: .NET SDK
- `python`: Python configuration
- `npm`: npm packages
- `git`: Git LFS
- `docker`: Docker verification

## Next Steps

After development tools are configured, the dotfiles role will set up your shell environment with aliases and Git configuration.

See: [Dotfiles Role Documentation](DOTFILES.md)
