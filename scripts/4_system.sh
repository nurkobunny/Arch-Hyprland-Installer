#!/bin/bash
source "$(dirname "$0")/header.sh"

DOTS_REPO="https://github.com/nurkobunny/DotsHyprland.git"
TEMP_DIR="$HOME/NurkoSystem_Temp"
git clone "$DOTS_REPO" "$TEMP_DIR" > /dev/null 2>&1

echo "${INFO} Configuring system components (requires SUDO)..."

# 1. SDDM
if [ -f /usr/bin/sddm ]; then
    echo "${NOTE} Setting up SDDM Theme..."
    sudo cp -r "$TEMP_DIR/sddm/simple_sddm_2/" /usr/share/sddm/themes/
    sudo cp "$TEMP_DIR/sddm/sddm.conf" /etc/
    sudo systemctl enable sddm
fi

# 2. GRUB
if [ -d /boot/grub ]; then
    echo "${NOTE} Setting up GRUB Theme..."
    sudo cp -r "$TEMP_DIR/grub/"* /usr/share/grub/themes/
    # Safely replace theme string
    sudo sed -i 's|^#GRUB_THEME=.*|GRUB_THEME="/usr/share/grub/themes/tartarus/theme.txt"|' /etc/default/grub
    sudo sed -i 's|^GRUB_THEME=.*|GRUB_THEME="/usr/share/grub/themes/tartarus/theme.txt"|' /etc/default/grub
    sudo grub-mkconfig -o /boot/grub/grub.cfg
fi

# 3. Sudoers (Safe Method)
echo "${NOTE} Configuring sudo permissions for Hyprland theme switching..."
SUDOERS_FILE="/etc/sudoers.d/hyprland-dots"
USER_NAME=$(whoami)
sudo bash -c "cat > $SUDOERS_FILE" <<EOF
# NurkoDots Hyprland permissions for user $USER_NAME
$USER_NAME ALL=(ALL) NOPASSWD: /usr/bin/sed *, /etc/default/grub
$USER_NAME ALL=(ALL) NOPASSWD: /usr/bin/sed *, /usr/share/sddm/themes/simple_sddm_2/metadata.desktop
$USER_NAME ALL=(ALL) NOPASSWD: /usr/bin/grub-mkconfig *
$USER_NAME ALL=(ALL) NOPASSWD: /usr/bin/sed *, /boot/grub/themes
$USER_NAME ALL=(ALL) NOPASSWD: /bin/cp
EOF
sudo chmod 0440 "$SUDOERS_FILE"

# 4. Input Group (for Waybar keyboard state)
sudo usermod -aG input "$USER_NAME"

rm -rf "$TEMP_DIR"
echo "${OK} System configuration complete."
