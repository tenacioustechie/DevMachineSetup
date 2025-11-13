#!/bin/bash

################################################################################
# Mac Development Machine Setup Script
#
# This script automates the setup of a macOS development environment
# Similar to the Windows setup.ps1 approach - direct and simple
#
# Usage:
#   ./setup.sh [--skip-xcode] [--config path/to/config.sh]
#
# Options:
#   --skip-xcode    Skip Xcode installation prompt
#   --config FILE   Use custom configuration file
################################################################################

set -e  # Exit on error
set -u  # Exit on undefined variable

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Script directory
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CONFIG_FILE="${SCRIPT_DIR}/config.sh"

# Parse command line arguments
SKIP_XCODE=false
while [[ $# -gt 0 ]]; do
    case $1 in
        --skip-xcode)
            SKIP_XCODE=true
            shift
            ;;
        --config)
            CONFIG_FILE="$2"
            shift 2
            ;;
        *)
            echo -e "${RED}Unknown option: $1${NC}"
            exit 1
            ;;
    esac
done

################################################################################
# Helper Functions
################################################################################

log_info() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

log_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

log_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

log_section() {
    echo ""
    echo -e "${GREEN}========================================${NC}"
    echo -e "${GREEN}$1${NC}"
    echo -e "${GREEN}========================================${NC}"
    echo ""
}

# Check if command exists
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# Check if Homebrew cask is installed
cask_installed() {
    brew list --cask "$1" >/dev/null 2>&1
}

# Check if Homebrew formula is installed
formula_installed() {
    brew list "$1" >/dev/null 2>&1
}

# Retry a command with exponential backoff
retry_command() {
    local max_attempts="$1"
    shift
    local delay=5
    local attempt=1

    while [ $attempt -le $max_attempts ]; do
        if "$@"; then
            return 0
        fi

        if [ $attempt -lt $max_attempts ]; then
            log_warning "Attempt $attempt/$max_attempts failed. Retrying in ${delay}s..."
            sleep $delay
            delay=$((delay * 2))
        fi
        attempt=$((attempt + 1))
    done

    log_error "Command failed after $max_attempts attempts"
    return 1
}

################################################################################
# Configuration Validation
################################################################################

validate_config() {
    log_section "Configuration Validation"

    local config_warnings=0

    # Define expected variables (add new ones here as the config evolves)
    local expected_vars=(
        "NODE_VERSION"
        "DOTNET_SDK_VERSION"
        "GIT_DEFAULT_BRANCH"
        "TIMEZONE"
        "NODEJS_GLOBAL_PACKAGES"
        "HOMEBREW_PACKAGES"
        "HOMEBREW_CASKS"
        "VSCODE_EXTENSIONS"
        "MACOS_DOCK_AUTOHIDE"
        "MACOS_FINDER_SHOW_HIDDEN"
        "INSTALL_XCODE"
    )

    log_info "Checking configuration completeness..."

    # Check for missing variables
    for var in "${expected_vars[@]}"; do
        if [[ -z "${!var+x}" ]]; then
            log_warning "Config variable '$var' is not defined in your config.sh"
            config_warnings=$((config_warnings + 1))
        fi
    done

    # Check if config.sh is older than config.example.sh
    if [[ -f "${SCRIPT_DIR}/config.example.sh" ]] && [[ -f "$CONFIG_FILE" ]]; then
        if [[ "${SCRIPT_DIR}/config.example.sh" -nt "$CONFIG_FILE" ]]; then
            log_warning "config.example.sh has been updated since your config.sh was last modified"
            log_info "Consider reviewing config.example.sh for new configuration options"
            config_warnings=$((config_warnings + 1))
        fi
    fi

    if [[ $config_warnings -gt 0 ]]; then
        echo ""
        log_warning "Found $config_warnings configuration warning(s)"
        log_info "Your setup will continue, but you may want to update your config.sh"
        log_info "Compare with: diff $CONFIG_FILE ${SCRIPT_DIR}/config.example.sh"
        echo ""

        # Give user a chance to cancel
        read -p "Continue anyway? (y/N) " -n 1 -r
        echo
        if [[ ! $REPLY =~ ^[Yy]$ ]]; then
            log_info "Setup cancelled. Please update your config.sh and try again."
            exit 0
        fi
    else
        log_success "Configuration validation passed"
    fi
}

################################################################################
# Pre-flight Checks
################################################################################

preflight_checks() {
    log_section "Pre-flight Checks"

    # Check macOS version
    log_info "Checking macOS version..."
    local macos_version=$(sw_vers -productVersion)
    log_info "macOS version: $macos_version"

    # Check architecture
    local arch=$(uname -m)
    log_info "Architecture: $arch"

    if [[ "$arch" == "arm64" ]]; then
        HOMEBREW_PREFIX="/opt/homebrew"
    else
        HOMEBREW_PREFIX="/usr/local"
    fi

    export HOMEBREW_PREFIX

    # Check available disk space
    local available_space=$(df -h / | awk 'NR==2 {print $4}')
    log_info "Available disk space: $available_space"

    log_success "Pre-flight checks complete"
}

################################################################################
# Xcode Command Line Tools
################################################################################

install_xcode_tools() {
    log_section "Xcode Command Line Tools"

    if xcode-select -p >/dev/null 2>&1; then
        log_success "Xcode Command Line Tools already installed"
        return 0
    fi

    log_info "Installing Xcode Command Line Tools..."
    log_warning "A dialog will appear. Please click 'Install' and wait for completion."

    xcode-select --install 2>/dev/null || true

    log_info "Waiting for installation to complete..."
    until xcode-select -p >/dev/null 2>&1; do
        sleep 5
    done

    log_success "Xcode Command Line Tools installed"
}

################################################################################
# Homebrew
################################################################################

install_homebrew() {
    log_section "Homebrew Installation"

    if command_exists brew; then
        log_success "Homebrew already installed"
        log_info "Updating Homebrew..."
        brew update || log_warning "Homebrew update failed, continuing..."
        return 0
    fi

    log_info "Installing Homebrew..."
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

    # Add Homebrew to PATH for current session
    if [[ -f "${HOMEBREW_PREFIX}/bin/brew" ]]; then
        eval "$(${HOMEBREW_PREFIX}/bin/brew shellenv)"
    fi

    log_success "Homebrew installed"
}

install_homebrew_packages() {
    log_section "Installing Homebrew Packages"

    for package in "${HOMEBREW_PACKAGES[@]}"; do
        if formula_installed "$package"; then
            log_info "✓ $package already installed"
        else
            log_info "Installing $package..."
            brew install "$package" || log_warning "Failed to install $package"
        fi
    done

    log_success "Homebrew packages installation complete"
}

install_homebrew_casks() {
    log_section "Installing Homebrew Casks (Applications)"

    for cask in "${HOMEBREW_CASKS[@]}"; do
        if cask_installed "$cask"; then
            log_info "✓ $cask already installed"
        else
            log_info "Installing $cask..."
            brew install --cask "$cask" || log_warning "Failed to install $cask"
        fi
    done

    log_success "Homebrew casks installation complete"
}

################################################################################
# Development Tools
################################################################################

setup_node() {
    log_section "Node.js Setup (via fnm)"

    # Ensure fnm is installed
    if ! command_exists fnm; then
        log_error "fnm not found. It should have been installed via Homebrew."
        return 1
    fi

    # Initialize fnm for current session
    eval "$(fnm env --use-on-cd)"

    # Check if Node.js version is already installed
    if fnm list | grep -q "v${NODE_VERSION}"; then
        log_success "Node.js v${NODE_VERSION} already installed"
    else
        log_info "Installing Node.js v${NODE_VERSION}..."

        # Clean up any partial downloads
        rm -rf ~/.local/share/fnm/node-versions/.downloads 2>/dev/null || true
        rm -rf ~/.local/share/fnm/node-versions/v${NODE_VERSION} 2>/dev/null || true

        # Install with retry logic
        retry_command 3 fnm install "${NODE_VERSION}"
    fi

    # Set as default
    log_info "Setting Node.js v${NODE_VERSION} as default..."
    fnm use "${NODE_VERSION}"
    fnm default "${NODE_VERSION}"

    # Verify installation
    node --version
    npm --version

    log_success "Node.js setup complete"
}

install_npm_packages() {
    log_section "Installing Global npm Packages"

    # Ensure fnm is initialized
    eval "$(fnm env --use-on-cd)" 2>/dev/null || true

    for package in "${NODEJS_GLOBAL_PACKAGES[@]}"; do
        if npm list -g "$package" >/dev/null 2>&1; then
            log_info "✓ $package already installed"
        else
            log_info "Installing $package..."
            npm install -g "$package" || log_warning "Failed to install $package"
        fi
    done

    log_success "npm packages installation complete"
}

setup_dotnet() {
    log_section ".NET SDK Setup"

    local dotnet_cask="dotnet-sdk@${DOTNET_SDK_VERSION}"

    if cask_installed "$dotnet_cask"; then
        log_success ".NET SDK ${DOTNET_SDK_VERSION} already installed"
    else
        log_info "Installing .NET SDK ${DOTNET_SDK_VERSION}..."
        log_warning "This may require your password for system installation..."

        # Note: .pkg installers require sudo, but Homebrew handles this via prompt
        # NOT by running brew as root
        brew install --cask "$dotnet_cask" || log_warning "Failed to install .NET SDK"
    fi

    # Verify installation
    if command_exists dotnet; then
        local dotnet_version=$(dotnet --version)
        log_success ".NET SDK installed: $dotnet_version"
    else
        log_warning ".NET SDK not found in PATH. You may need to restart your shell."
    fi
}

################################################################################
# Shell Configuration
################################################################################

setup_shell_config() {
    log_section "Shell Configuration"

    local zshrc="$HOME/.zshrc"
    local marker_begin="# BEGIN MAC DEV SETUP - AUTO CONFIGURED"
    local marker_end="# END MAC DEV SETUP - AUTO CONFIGURED"

    # Remove old configuration if exists
    if grep -q "$marker_begin" "$zshrc" 2>/dev/null; then
        log_info "Removing old configuration..."
        sed -i.backup "/$marker_begin/,/$marker_end/d" "$zshrc"
    fi

    log_info "Adding configuration to ~/.zshrc..."

    cat >> "$zshrc" <<EOF

$marker_begin

# Homebrew
eval "\$(${HOMEBREW_PREFIX}/bin/brew shellenv)"

# fnm (Fast Node Manager)
eval "\$(fnm env --use-on-cd)"

# .NET SDK
export PATH="/usr/local/share/dotnet:\$PATH"
export DOTNET_ROOT="/usr/local/share/dotnet"

# Common aliases
alias ll='ls -lah'
alias gs='git status'
alias gp='git pull'
alias gc='git commit'
alias gd='git diff'

# Modern CLI tools (if installed)
if command -v eza >/dev/null 2>&1; then
    alias ls='eza'
    alias ll='eza -lah'
fi

if command -v bat >/dev/null 2>&1; then
    alias cat='bat'
fi

$marker_end
EOF

    log_success "Shell configuration updated"
    log_info "Run 'source ~/.zshrc' or restart your terminal to apply changes"
}

setup_git_config() {
    log_section "Git Configuration"

    # Only configure if values are provided
    if [[ -n "${GIT_USER_NAME:-}" ]]; then
        log_info "Setting Git user name: $GIT_USER_NAME"
        git config --global user.name "$GIT_USER_NAME"
    else
        log_info "Skipping Git user name (not configured)"
    fi

    if [[ -n "${GIT_USER_EMAIL:-}" ]]; then
        log_info "Setting Git user email: $GIT_USER_EMAIL"
        git config --global user.email "$GIT_USER_EMAIL"
    else
        log_info "Skipping Git user email (not configured)"
    fi

    if [[ -n "${GIT_DEFAULT_BRANCH:-}" ]]; then
        log_info "Setting Git default branch: $GIT_DEFAULT_BRANCH"
        git config --global init.defaultBranch "$GIT_DEFAULT_BRANCH"
    fi

    # Common Git settings
    log_info "Configuring common Git settings..."
    git config --global pull.rebase false
    git config --global core.autocrlf input
    git config --global core.editor "code --wait" 2>/dev/null || true

    # Configure Kdiff3 as merge and diff tool (if installed)
    if command_exists kdiff3; then
        log_info "Configuring Kdiff3 as Git merge and diff tool..."

        # Set kdiff3 as the merge tool
        git config --global merge.tool kdiff3
        git config --global mergetool.kdiff3.path "$(command -v kdiff3)"
        git config --global mergetool.kdiff3.trustExitCode false
        git config --global mergetool.keepBackup false

        # Set kdiff3 as the diff tool
        git config --global diff.tool kdiff3
        git config --global difftool.kdiff3.path "$(command -v kdiff3)"
        git config --global difftool.kdiff3.trustExitCode false

        # Don't prompt before opening kdiff3
        git config --global difftool.prompt false
        git config --global mergetool.prompt false

        log_success "Kdiff3 configured as Git merge/diff tool"
    else
        log_info "Kdiff3 not installed, skipping Git merge/diff tool configuration"
        log_info "Kdiff3 will be configured on next setup run after installation"
    fi

    log_success "Git configuration complete"
}

################################################################################
# macOS Preferences
################################################################################

setup_macos_preferences() {
    log_section "macOS Preferences"

    # Set timezone if configured
    if [[ -n "${TIMEZONE:-}" ]]; then
        log_info "Setting system timezone to: $TIMEZONE"
        sudo systemsetup -settimezone "$TIMEZONE" 2>/dev/null || log_warning "Failed to set timezone (may require manual configuration)"
    fi

    log_info "Configuring Dock preferences..."

    # Dock settings
    defaults write com.apple.dock autohide -bool "${MACOS_DOCK_AUTOHIDE:-true}"
    defaults write com.apple.dock autohide-delay -float "${MACOS_DOCK_AUTOHIDE_DELAY:-0}"
    defaults write com.apple.dock tilesize -int "${MACOS_DOCK_TILESIZE:-48}"
    defaults write com.apple.dock show-recents -bool "${MACOS_DOCK_SHOW_RECENTS:-false}"
    defaults write com.apple.dock minimize-to-application -bool "${MACOS_DOCK_MINIMIZE_TO_APP:-true}"

    log_info "Configuring Finder preferences..."

    # Finder settings
    defaults write com.apple.finder AppleShowAllFiles -bool "${MACOS_FINDER_SHOW_HIDDEN:-true}"
    defaults write NSGlobalDomain AppleShowAllExtensions -bool "${MACOS_FINDER_SHOW_EXTENSIONS:-true}"
    defaults write com.apple.finder ShowPathbar -bool "${MACOS_FINDER_SHOW_PATH_BAR:-true}"
    defaults write com.apple.finder ShowStatusBar -bool "${MACOS_FINDER_SHOW_STATUS_BAR:-true}"
    defaults write com.apple.finder FXPreferredViewStyle -string "${MACOS_FINDER_VIEW_STYLE:-Nlsv}"
    defaults write com.apple.finder FXEnableExtensionChangeWarning -bool false

    log_info "Configuring screenshot preferences..."

    # Screenshot settings
    local screenshot_location="${MACOS_SCREENSHOT_LOCATION:-$HOME/Screenshots}"
    mkdir -p "$screenshot_location"
    defaults write com.apple.screencapture location -string "$screenshot_location"
    defaults write com.apple.screencapture type -string "${MACOS_SCREENSHOT_FORMAT:-png}"
    defaults write com.apple.screencapture disable-shadow -bool "${MACOS_SCREENSHOT_DISABLE_SHADOW:-false}"

    log_info "Configuring trackpad preferences..."

    # Trackpad settings
    defaults write com.apple.driver.AppleBluetoothMultitouch.trackpad Clicking -bool "${MACOS_TRACKPAD_TAP_TO_CLICK:-true}"
    defaults write NSGlobalDomain com.apple.mouse.tapBehavior -int 1

    log_info "Configuring keyboard preferences..."

    # Keyboard settings
    defaults write NSGlobalDomain KeyRepeat -int "${MACOS_KEYBOARD_KEY_REPEAT:-2}"
    defaults write NSGlobalDomain InitialKeyRepeat -int "${MACOS_KEYBOARD_INITIAL_REPEAT:-15}"

    # Function keys mode (true = F1-F12 work as standard function keys)
    if [[ "${MACOS_KEYBOARD_FNKEYS_STANDARD:-false}" == true ]]; then
        defaults write NSGlobalDomain com.apple.keyboard.fnState -bool true
        log_info "F1-F12 keys set to standard function mode"
    fi

    log_info "Restarting affected applications..."
    killall Dock 2>/dev/null || true
    killall Finder 2>/dev/null || true
    killall SystemUIServer 2>/dev/null || true

    log_success "macOS preferences configured"
}

################################################################################
# Application Configuration
################################################################################

setup_vscode() {
    log_section "VS Code Configuration"

    if ! command_exists code; then
        log_warning "VS Code not found. Skipping extension installation."
        log_info "After VS Code is installed, run: code --install-extension <extension-id>"
        return 0
    fi

    log_info "Installing VS Code extensions..."

    for extension in "${VSCODE_EXTENSIONS[@]}"; do
        if code --list-extensions | grep -q "$extension"; then
            log_info "✓ $extension already installed"
        else
            log_info "Installing $extension..."
            code --install-extension "$extension" --force || log_warning "Failed to install $extension"
        fi
    done

    log_success "VS Code configuration complete"
}

################################################################################
# Optional: Xcode
################################################################################

install_xcode() {
    log_section "Xcode Installation"

    if [[ "$SKIP_XCODE" == true ]]; then
        log_info "Skipping Xcode installation (--skip-xcode flag)"
        return 0
    fi

    if [[ "${INSTALL_XCODE:-false}" != true ]]; then
        log_info "Xcode installation not enabled in config"
        return 0
    fi

    log_info "Checking for Xcode..."

    if [[ -d "/Applications/Xcode.app" ]]; then
        log_success "Xcode already installed"

        # Accept license
        log_info "Accepting Xcode license..."
        sudo xcodebuild -license accept 2>/dev/null || log_warning "Could not accept Xcode license automatically"

        return 0
    fi

    log_warning "Xcode installation requires Mac App Store"
    log_info "Please install Xcode manually from the Mac App Store"
    log_info "Or run: mas install 497799835"
}

################################################################################
# Main Setup Flow
################################################################################

main() {
    log_section "Mac Development Machine Setup"
    log_info "Starting setup process..."

    # Load configuration
    if [[ ! -f "$CONFIG_FILE" ]]; then
        log_error "Configuration file not found: $CONFIG_FILE"
        echo ""
        log_info "This appears to be your first time running the setup."
        log_info "Please create your personal configuration file:"
        echo ""
        echo "  cd $SCRIPT_DIR"
        echo "  cp config.example.sh config.sh"
        echo ""
        log_info "Then edit config.sh with your personal settings (name, email, etc.)"
        log_info "The config.sh file is gitignored and won't be committed to the repository."
        echo ""
        exit 1
    fi

    log_info "Loading configuration from: $CONFIG_FILE"
    source "$CONFIG_FILE"

    # Validate configuration
    validate_config

    # Run setup steps
    preflight_checks
    install_xcode_tools
    install_homebrew
    install_homebrew_packages
    install_homebrew_casks
    setup_node
    install_npm_packages
    setup_dotnet
    setup_shell_config
    setup_git_config
    setup_macos_preferences
    setup_vscode
    install_xcode

    # Final cleanup
    log_section "Cleanup"
    log_info "Running Homebrew cleanup..."
    brew cleanup || log_warning "Homebrew cleanup failed"

    # Summary
    log_section "Setup Complete!"
    log_success "Your Mac development environment is ready!"
    echo ""
    log_info "Next steps:"
    echo "  1. Restart your terminal or run: source ~/.zshrc"
    echo "  2. Verify installations:"
    echo "     - node --version"
    echo "     - npm --version"
    echo "     - dotnet --version"
    echo "     - git --version"
    echo ""
    log_info "To customize your setup, edit: $CONFIG_FILE"
    log_info "To run again: ./setup.sh"
    echo ""
}

# Run main function
main "$@"
