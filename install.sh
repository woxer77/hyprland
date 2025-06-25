#!/bin/bash

set -ex  # Остановиться при ошибке и печатать команды

USERNAME="woxer"
USER_HOME="/home/$USERNAME"
REPO_DIR="$(pwd)/hyprland"  # Предполагаем, что скрипт запускается из корня репозитория
WG_SCRIPT="$USER_HOME/scripts/wireguard-install.sh"

# Проверка и создание пользователя
if ! id "$USERNAME" &>/dev/null; then
  echo "[+] Creating user $USERNAME..."
  useradd -m -G wheel -s /bin/bash "$USERNAME"
fi

# Убедимся, что домашняя директория существует
if [ ! -d "$USER_HOME" ]; then
  echo "[-] Home directory $USER_HOME does not exist"
  exit 1
fi

# Обновление системы и установка базовых пакетов
echo "[+] Installing base tools..."
pacman -Syu --noconfirm
pacman -Sy --noconfirm git curl base base-devel sudo

# Установка yay, если не установлен
if ! command -v yay &>/dev/null; then
  echo "[+] Installing yay..."
  cd /tmp
  git clone https://aur.archlinux.org/yay.git
  chown -R "$USERNAME:$USERNAME" yay
  cd yay
  sudo -u "$USERNAME" makepkg -si --noconfirm
fi

# Установка пакетов из pacman.txt
if [ -f "$REPO_DIR/packages/pacman.txt" ]; then
  echo "[+] Installing pacman packages..."
  pacman -Sy --needed --noconfirm $(grep -vE '^\s*#|^\s*$' "$REPO_DIR/packages/pacman.txt")
else
  echo "[-] File packages/pacman.txt not found!"
fi

# Установка пакетов из yay.txt
if [ -f "$REPO_DIR/packages/yay.txt" ]; then
  echo "[+] Installing yay packages..."
  sudo -u "$USERNAME" yay -Sy --needed --noconfirm $(grep -vE '^\s*#|^\s*$' "$REPO_DIR/packages/yay.txt")
else
  echo "[-] File packages/yay.txt not found!"
fi

# Downloading fonts from Google Fonts
mkdir -p ~/.local/share/fonts
cd ~/.local/share/fonts
wget https://github.com/google/fonts/raw/main/ofl/rubikwetpaint/RubikWetPaint-Regular.ttf


# Копирование конфигов
echo "[+] Copying configs..."
if [ -d "$REPO_DIR/configs/.config" ]; then
  cp -r "$REPO_DIR/configs/.config" "$USER_HOME/"
fi

if [ -f "$REPO_DIR/configs/.bashrc" ]; then
  cp "$REPO_DIR/configs/.bashrc" "$USER_HOME/.bashrc"
fi

  cp "$REPO_DIR/VSCode/keybindings.json" "$USER_HOME/.config/Code/User/"
  cp "$REPO_DIR/configs/.bash_profile" "$USER_HOME/"

# Права
chown -R "$USERNAME:$USERNAME" "$USER_HOME/.config" "$USER_HOME/.bashrc" 2>/dev/null || true

mkdir -p ~/Downloads

# Копирование скриптов и обоев
echo "[+] Copying scripts and wallpapers..."
if [ -d "$REPO_DIR/scripts" ]; then
  mv "$REPO_DIR/scripts/volume-down.sh" /usr/local/bin/
  mv "$REPO_DIR/scripts/volume-up.sh" /usr/local/bin/
  mv "$REPO_DIR/scripts/unzip_to_folder" /usr/local/bin/
fi
if [ -d "$REPO_DIR/Wallpapers" ]; then
  cp -r "$REPO_DIR/Wallpapers" "$USER_HOME/Wallpapers"
fi

chown -R "$USERNAME:$USERNAME" "$USER_HOME/scripts" "$USER_HOME/Wallpapers" 2>/dev/null || true

# Настройка sudoers для wireguard
echo "[+] Configuring sudoers for wg-quick..."
{
  echo ""
  echo "$USERNAME ALL=(ALL) NOPASSWD: /usr/bin/wg-quick up /home/$USERNAME/.config/wireguard/wg-client.conf"
  echo "$USERNAME ALL=(ALL) NOPASSWD: /usr/bin/wg-quick down /home/$USERNAME/.config/wireguard/wg-client.conf"
} >> /etc/sudoers

# Инициализируем wireguard
if [[ -f "$WG_SCRIPT" ]]; then
    echo "Launching WireGuard installation..."
    bash "$WG_SCRIPT"
else
    echo "Error: Script $WG_SCRIPT wasn't found!"
fi

echo "[✓] Hyprland environment installed and configured successfully!"
