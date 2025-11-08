#!/bin/bash

# Mac Dev Machine Bootstrap Script
# This script prepares your Mac for automated setup by installing prerequisites
# and running the Ansible playbook

set -e  # Exit on error

echo "=========================================="
echo "Mac Development Machine Setup"
echo "=========================================="
echo ""

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Function to print colored output
print_status() {
    echo -e "${GREEN}[✓]${NC} $1"
}

print_error() {
    echo -e "${RED}[✗]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[!]${NC} $1"
}

# Check if running on macOS
if [[ "$OSTYPE" != "darwin"* ]]; then
    print_error "This script is designed for macOS only"
    exit 1
fi

print_status "Running on macOS"

# Check and install Xcode Command Line Tools
echo ""
echo "Checking for Xcode Command Line Tools..."
if ! xcode-select -p &> /dev/null; then
    print_warning "Xcode Command Line Tools not found. Installing..."
    xcode-select --install
    echo ""
    print_warning "Please complete the Xcode Command Line Tools installation in the dialog"
    print_warning "Then run this script again"
    exit 0
else
    print_status "Xcode Command Line Tools already installed"
fi

# Check and install Homebrew
echo ""
echo "Checking for Homebrew..."
if ! command -v brew &> /dev/null; then
    print_warning "Homebrew not found. Installing..."
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

    # Add Homebrew to PATH for Apple Silicon Macs
    if [[ $(uname -m) == 'arm64' ]]; then
        echo 'eval "$(/opt/homebrew/bin/brew shellenv)"' >> ~/.zprofile
        eval "$(/opt/homebrew/bin/brew shellenv)"
    fi

    print_status "Homebrew installed successfully"
else
    print_status "Homebrew already installed"
fi

# Update Homebrew
echo ""
echo "Updating Homebrew..."
brew update

# Check and install Ansible
echo ""
echo "Checking for Ansible..."
if ! command -v ansible &> /dev/null; then
    print_warning "Ansible not found. Installing via Homebrew..."
    brew install ansible
    print_status "Ansible installed successfully"
else
    print_status "Ansible already installed"
fi

# Display versions
echo ""
echo "Installed versions:"
echo "  Homebrew: $(brew --version | head -n 1)"
echo "  Ansible: $(ansible --version | head -n 1)"

# Install Ansible Galaxy requirements
echo ""
if [ -f "requirements.yml" ]; then
    echo "Installing Ansible Galaxy requirements..."
    ansible-galaxy install -r requirements.yml
    print_status "Ansible Galaxy requirements installed"
else
    print_warning "No requirements.yml found, skipping Galaxy requirements"
fi

# Prompt for configuration options
echo ""
echo "=========================================="
echo "Configuration Options"
echo "=========================================="
echo ""

read -p "Do you want to install Xcode and iOS development tools? (y/N): " install_xcode
if [[ $install_xcode =~ ^[Yy]$ ]]; then
    INSTALL_XCODE="true"
else
    INSTALL_XCODE="false"
fi

# Run the Ansible playbook
echo ""
echo "=========================================="
echo "Running Ansible Playbook"
echo "=========================================="
echo ""

ANSIBLE_EXTRA_VARS="install_xcode=$INSTALL_XCODE"

print_status "Starting playbook execution..."
echo ""

ansible-playbook -i inventory.yml playbook.yml \
    --extra-vars "$ANSIBLE_EXTRA_VARS" \
    --ask-become-pass

echo ""
echo "=========================================="
echo "Setup Complete!"
echo "=========================================="
echo ""
print_status "Your Mac development environment has been configured"
echo ""
echo "Next steps:"
echo "  1. Restart your terminal to load new configurations"
echo "  2. Review installed applications in /Applications"
echo "  3. Customize any application settings as needed"
echo ""
echo "To update your setup in the future, run:"
echo "  ./bootstrap.sh"
echo ""
