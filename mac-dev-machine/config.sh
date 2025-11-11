#!/bin/bash

################################################################################
# Mac Development Machine Configuration
#
# Edit this file to customize your development environment
# This file is sourced by setup.sh
################################################################################

################################################################################
# Node.js Configuration
################################################################################

NODE_VERSION="20.15.0"  # Node.js version to install via fnm

# Global npm packages to install
NODEJS_GLOBAL_PACKAGES=(
    "@angular/cli"
    "typescript"
    "ts-node"
    "yarn"
    "pnpm"
    "npm-check-updates"
)

################################################################################
# .NET Configuration
################################################################################

DOTNET_SDK_VERSION="8"  # .NET SDK version (matches Homebrew cask: dotnet-sdk@8)

################################################################################
# Git Configuration
################################################################################

GIT_USER_NAME=""          # Set your name or leave empty to skip
GIT_USER_EMAIL=""         # Set your email or leave empty to skip
GIT_DEFAULT_BRANCH="main" # Default branch name for new repositories

################################################################################
# Homebrew Packages (CLI Tools)
################################################################################

HOMEBREW_PACKAGES=(
    # Version Control
    "git"
    #"git-lfs"

    # Core Development Tools
    "wget"
    "curl"
    "jq"
    "tree"
    "htop"

    # Node.js Version Manager (fnm is faster than nvm)
    "fnm"

    # Python
    "python@3.11"

    # Database Tools
    #"postgresql@15"

    # Cloud & DevOps
    "awscli"
    #"terraform"
    "docker"
    "docker-compose"

    # Utilities
    "ripgrep"
    "fzf"
    "bat"
    "eza"    # Modern replacement for ls
    "tldr"   # Simplified man pages

    # Compression
    "unzip"
    "p7zip"
)

################################################################################
# Homebrew Casks (GUI Applications)
################################################################################

HOMEBREW_CASKS=(
    # Development IDEs & Editors
    "visual-studio-code"
    "datagrip"

    # Terminals
    "iterm2"

    # Browsers
    "google-chrome"
    "firefox"

    # Communication
    # "slack"  # Commented out - uncomment if needed
    "zoom"

    # Utilities
    "rectangle"   # Window management (free)
    "raycast"     # Spotlight replacement with plugins
    "maccy"       # Clipboard manager

    # Media
    "spotify"
    "vlc"

    # Productivity
    "notion"
    "obsidian"

    # Development Tools
    "docker"
    "postman"

    # Fonts
    "font-jetbrains-mono"
    "font-fira-code"
    "font-hack-nerd-font"
)

################################################################################
# VS Code Extensions
################################################################################

VSCODE_EXTENSIONS=(
    "ms-vscode.csharp"
    "ms-dotnettools.csdevkit"
    "dbaeumer.vscode-eslint"
    "esbenp.prettier-vscode"
    # "angular.ng-template"           # Commented out - uncomment if needed
    # "ms-python.python"              # Commented out - uncomment if needed
    # "ms-azuretools.vscode-docker"   # Commented out - uncomment if needed
    "eamodio.gitlens"
    "pkief.material-icon-theme"
    "github.copilot"
    "editorconfig.editorconfig"
    "bradlc.vscode-tailwindcss"
    "hashicorp.terraform"
)

################################################################################
# macOS Preferences
################################################################################

# Dock Settings
MACOS_DOCK_AUTOHIDE=true
MACOS_DOCK_AUTOHIDE_DELAY=0
MACOS_DOCK_TILESIZE=48
MACOS_DOCK_SHOW_RECENTS=false
MACOS_DOCK_MINIMIZE_TO_APP=true

# Finder Settings
MACOS_FINDER_SHOW_HIDDEN=true
MACOS_FINDER_SHOW_EXTENSIONS=true
MACOS_FINDER_SHOW_PATH_BAR=true
MACOS_FINDER_SHOW_STATUS_BAR=true
MACOS_FINDER_VIEW_STYLE="Nlsv"  # List view (Nlsv=list, icnv=icon, clmv=column, glyv=gallery)

# Screenshot Settings
MACOS_SCREENSHOT_LOCATION="$HOME/Screenshots"
MACOS_SCREENSHOT_FORMAT="png"  # png, jpg, pdf, tiff
MACOS_SCREENSHOT_DISABLE_SHADOW=false

# Trackpad Settings
MACOS_TRACKPAD_TAP_TO_CLICK=true

# Keyboard Settings
MACOS_KEYBOARD_KEY_REPEAT=2         # Lower = faster (requires logout)
MACOS_KEYBOARD_INITIAL_REPEAT=15    # Lower = shorter delay (requires logout)

################################################################################
# Optional Tools Configuration
################################################################################

INSTALL_XCODE=false  # Set to true to install Xcode from Mac App Store

################################################################################
# Notes
################################################################################

# Package Names:
# - Find Homebrew packages: https://formulae.brew.sh/
# - Find casks: https://formulae.brew.sh/cask/
# - Find VS Code extensions: https://marketplace.visualstudio.com/
#
# All taps (homebrew/cask, homebrew/cask-fonts, homebrew/cask-versions) are
# deprecated as of 2024. All casks and fonts are now in homebrew/cask by default.
#
# For versioned casks, use the @version suffix:
#   - dotnet-sdk@8
#   - firefox@developer-edition
#
# To run setup: ./setup.sh
# To skip Xcode prompt: ./setup.sh --skip-xcode
# To use custom config: ./setup.sh --config path/to/config.sh
