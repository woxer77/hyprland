#!/bin/bash

set -e

USERNAME="woxer"
USER_HOME="/home/$USERNAME"
REPO_DIR="$(pwd)"

echo "[+] Installing base tools..."
pacman -Sy --noconfirm git curl base base-devel

if ! command -v yay &> /dev/null; then
  echo "[+] Installing yay..."
  cd /tmp
  git clone https://aur.archlinux.org/yay.git
  chown -R "$USERNAME":"$USERNAME" yay
  cd yay
  sudo -u "$USERNAME" makepkg -si --noconfirm
fi

echo "[+] Installing pacman packages..."
pacman -Sy --needed --noconfirm $(cat "$REPO_DIR/packages/pacman.txt")

echo "[+] Installing yay packages..."
sudo -u "$USERNAME" yay -Sy --needed --noconfirm $(cat "$REPO_DIR/packages/yay.txt")

echo "[+] Copying configs..."
cp -r "$REPO_DIR/configs/.config" "$USER_HOME/"
cp "$REPO_DIR/configs/.bashrc" "$USER_HOME/.bashrc"
chown -R "$USERNAME:$USERNAME" "$USER_HOME/.config" "$USER_HOME/.bashrc"

echo "[+] Copying scripts and wallpapers..."
cp -r "$REPO_DIR/scripts" "$USER_HOME/scripts"
cp -r "$REPO_DIR/Wallpapers" "$USER_HOME/Wallpapers"
chown -R "$USERNAME:$USERNAME" "$USER_HOME/scripts" "$USER_HOME/Wallpapers"

echo "[+] Configuring sudoers..."
echo -e "\n$USERNAME ALL=(ALL) NOPASSWD: /usr/bin/wg-quick up /home/$USERNAME/.config/wireguard/wg-client.conf" >> /etc/sudoers
echo "$USERNAME ALL=(ALL) NOPASSWD: /usr/bin/wg-quick down /home/$USERNAME/.config/wireguard/wg-client.conf" >> /etc/sudoers

echo "[✓] Hyprland environment installed and configured!"
