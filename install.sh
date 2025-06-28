#!/bin/bash

set -euo pipefail
IFS=$'\n\t'

USER_HOME="/home/$USER"
REPO_DIR="$(pwd)"
WG_SCRIPT="$REPO_DIR/scripts/wireguard-install.sh"

# Ensure the script is not run as root
if [ "$EUID" -eq 0 ]; then
  echo "[-] Do not run this script as root. Use a normal user with sudo privileges."
  exit 1
fi

# System update and base tool installation
echo "[+] Updating system and installing essential tools..."
sudo pacman -Syu --noconfirm git wget curl base base-devel sudo

# Install yay if not already installed
if ! command -v yay &>/dev/null; then
  echo "[+] Installing yay (AUR helper)..."
  git clone https://aur.archlinux.org/yay.git /tmp/yay
  cd /tmp/yay
  makepkg -si --noconfirm
  cd -
  rm -rf /tmp/yay
fi

# Install packages from pacman.txt
if [ -f "$REPO_DIR/packages/pacman.txt" ]; then
  echo "[+] Installing packages from pacman.txt..."
  sudo pacman -Sy --needed --noconfirm $(grep -vE '^\s*#|^\s*$' "$REPO_DIR/packages/pacman.txt")
else
  echo "[-] File packages/pacman.txt not found!"
fi

# Install packages from yay.txt
if [ -f "$REPO_DIR/packages/yay.txt" ]; then
  echo "[+] Installing AUR packages from yay.txt..."
  yay -Sy --needed --noconfirm $(grep -vE '^\s*#|^\s*$' "$REPO_DIR/packages/yay.txt")
else
  echo "[-] File packages/yay.txt not found!"
fi

# Install wg_tool
yay -S wg_tool --mflags --skipinteg

# Download fonts
echo "[+] Downloading RubikWetPaint font..."
mkdir -p "$HOME/.local/share/fonts"
cd "$HOME/.local/share/fonts"
wget -q https://github.com/google/fonts/raw/main/ofl/rubikwetpaint/RubikWetPaint-Regular.ttf

# Copy configuration files (after packages are installed)
echo "[+] Copying configuration files..."
[ -d "$REPO_DIR/configs/.config" ] && cp -r "$REPO_DIR/configs/.config" "$HOME/"
[ -f "$REPO_DIR/configs/.bashrc" ] && cp "$REPO_DIR/configs/.bashrc" "$HOME/.bashrc"
[ -f "$REPO_DIR/configs/.bash_profile" ] && cp "$REPO_DIR/configs/.bash_profile" "$HOME/.bash_profile"

# Fix config permissions
chmod -R 755 "$HOME/.config" 2>/dev/null || true

# Ensure Downloads directory exists
mkdir -p "$HOME/Downloads"

# Copy custom scripts to /usr/local/bin
echo "[+] Installing custom user scripts..."
if [ -d "$REPO_DIR/scripts" ]; then
  sudo cp "$REPO_DIR/scripts/volume-down.sh" /usr/local/bin/
  sudo cp "$REPO_DIR/scripts/volume-up.sh" /usr/local/bin/
fi

# Copy wallpapers
if [ -d "$REPO_DIR/Wallpapers" ]; then
  cp -r "$REPO_DIR/Wallpapers" "$HOME/Wallpapers"
fi

# Prompt for WireGuard setup
read -rp "[?] Do you want to install and configure WireGuard? [y/N]: " INSTALL_WG
if [[ "$INSTALL_WG" =~ ^[Yy]$ ]]; then
  echo "[+] Configuring sudoers for WireGuard..."
  WG_CONF="$HOME/.config/wireguard/wg-client.conf"
  SUDOERS_LINE_UP="$USER ALL=(ALL) NOPASSWD: /usr/bin/wg-quick up $WG_CONF"
  SUDOERS_LINE_DOWN="$USER ALL=(ALL) NOPASSWD: /usr/bin/wg-quick down $WG_CONF"

  if ! sudo grep -qxF "$SUDOERS_LINE_UP" /etc/sudoers; then
    echo "$SUDOERS_LINE_UP" | sudo tee -a /etc/sudoers
  fi
  if ! sudo grep -qxF "$SUDOERS_LINE_DOWN" /etc/sudoers; then
    echo "$SUDOERS_LINE_DOWN" | sudo tee -a /etc/sudoers
  fi

  if [[ -f "$WG_SCRIPT" ]]; then
    echo "[+] Running WireGuard setup script..."
    sudo bash "$WG_SCRIPT"
  else
    echo "[-] WireGuard script $WG_SCRIPT not found!"
  fi
else
  echo "[!] Skipping WireGuard installation."
fi

# Prompt for Spicetify setup
read -rp "[?] Do you want to install Spicetify and Marketplace? [y/N]: " INSTALL_SPICETIFY
if [[ "$INSTALL_SPICETIFY" =~ ^[Yy]$ ]]; then
  echo "[+] Installing Spicetify CLI..."
  curl -fsSL https://raw.githubusercontent.com/spicetify/cli/main/install.sh | sh

  echo "[+] Installing Spicetify Marketplace..."
  curl -fsSL https://raw.githubusercontent.com/spicetify/marketplace/main/resources/install.sh | sh

  echo "[+] Copying Spicetify configuration..."
  if [ -d "$REPO_DIR/configs/.spicetify" ]; then
    cp -r "$REPO_DIR/configs/.spicetify" "$HOME/"
  else
    echo "[-] Spicetify config directory not found!"
  fi
else
  echo "[!] Skipping Spicetify installation."
fi

# reflector configuration (arch servers installation)
sudo reflector --latest 20 --sort rate --save /etc/pacman.d/mirrorlist

echo "[✓] Hyprland environment successfully installed and configured!"
