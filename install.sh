#!/bin/bash

set -euo pipefail
IFS=$'\n\t'

USER_HOME="/home/$USER"
REPO_DIR="$(pwd)"

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

# Download fonts
echo "[+] Downloading RubikWetPaint font..."
mkdir -p "$HOME/.local/share/fonts"
wget -q -O "$HOME/.local/share/fonts/RubikWetPaint-Regular.ttf" https://github.com/google/fonts/raw/main/ofl/rubikwetpaint/RubikWetPaint-Regular.ttf

# Copy configuration files (after packages are installed)
echo "[+] Copying configuration files..."
[ -d "$REPO_DIR/configs/.config" ] && cp -r "$REPO_DIR/configs/.config" "$HOME/"
[ -f "$REPO_DIR/configs/.bashrc" ] && cp "$REPO_DIR/configs/.bashrc" "$HOME/.bashrc"
[ -f "$REPO_DIR/configs/.bash_profile" ] && cp "$REPO_DIR/configs/.bash_profile" "$HOME/.bash_profile"

# Fix config permissions
chmod -R 755 "$HOME/.config" 2>/dev/null || true

# Create Downloads directory
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

# Ask before installing Gemini CLI
read -p "[?] Do you want to install Gemini CLI? (y/N): " gemini_choice
if [[ "$gemini_choice" =~ ^[Yy]$ ]]; then
  echo "[+] Installing Gemini CLI..."
  sudo npm install -g @google/gemini-cli
else
  echo "[-] Skipping Gemini CLI installation."
fi

# reflector configuration (arch servers installation)
sudo reflector --latest 20 --sort rate --save /etc/pacman.d/mirrorlist

# Configuring sudoers
echo "[+] Configuring sudoers..."
echo "$USER ALL=(ALL) NOPASSWD: /usr/bin/killall openvpn, /usr/sbin/openvpn --config $USER_HOME/.config/openvpn/openvpn.ovpn --daemon" | sudo tee -a /etc/sudoers

# Automatically mount disks so they can be accessible
echo "# Entry for 1TB HDD (sda1)" | sudo tee -a /etc/fstab 
echo "UUID=9E9A93F69A93C8E3 /mnt/d ntfs defaults,nofail 0 0" | sudo tee -a /etc/fstab
echo "# Entry for 1TB NVMe (nvme1n1p5)" | sudo tee -a /etc/fstab
echo "UUID=6A18EBE718EBAFED /mnt/e ntfs defaults,nofail 0 0" | sudo tee -a /etc/fstab

# Success

echo "[!] REMINDER: For OpenVPN place '.ovpn' configuration file in '$HOME/.config/openvpn/openvpn.ovpn'"
echo "[!] REMINDER: Don't forget to configure .ssh for GitHub"
echo "[!] REMINDER: Don't forget to put Gemini Api Key in .bashrc"
echo "[!] REMINDER: Don't forget to execute spicetify.ssh if needed"

echo "[✓] Hyprland environment successfully installed and configured!"
