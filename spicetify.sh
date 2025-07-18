# Install and configure Spicetify
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

echo "[+] Applying Spicetify configuration..."
/home/$USER/.spicetify/spicetify backup apply
/home/$USER/.spicetify/spicetify config custom_apps lyrics-plus
/home/$USER/.spicetify/spicetify apply
