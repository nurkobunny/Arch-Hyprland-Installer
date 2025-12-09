#!/bin/bash

# Define script directory
SCRIPT_DIR="$(dirname "$(readlink -f "$0")")/scripts"
source "$SCRIPT_DIR/header.sh"

# Check Whiptail
if ! command -v whiptail &>/dev/null; then
    echo "Installing whiptail..."
    sudo pacman -S --noconfirm libnewt
fi

# Show Logo
show_logo
read -p "Press Enter to start..."

# Selection Menu
options=$(whiptail --title "NurkoDots Installer" --checklist \
"Select components to install (Spacebar to select):" 20 78 10 \
"1" "Dependencies (Pacman & AUR Packages + Hyprland)" ON \
"2" "Dotfiles (Hyprland, Waybar, ZSH configs)" ON \
"3" "Themes (GTK, Icons, Wallpapers)" ON \
"4" "System (SDDM, GRUB, Sudoers)" OFF \
3>&1 1>&2 2>&3)

if [ $? -ne 0 ]; then
    echo "${ERROR} Installation cancelled."
    exit 0
fi

# Execute Modules
if [[ $options == *"1"* ]]; then
    bash "$SCRIPT_DIR/1_packages.sh"
fi

if [[ $options == *"2"* ]]; then
    bash "$SCRIPT_DIR/2_dots.sh"
fi

if [[ $options == *"3"* ]]; then
    bash "$SCRIPT_DIR/3_themes.sh"
fi

if [[ $options == *"4"* ]]; then
    bash "$SCRIPT_DIR/4_system.sh"
fi

# Final Summary
echo ""
echo "${MAGENTA}╔═════════════════════════════════════════════╗${RESET}"
echo "${MAGENTA}║      INSTALLATION COMPLETE! REBOOT NOW      ║${RESET}"
echo "${MAGENTA}╚═════════════════════════════════════════════╝${RESET}"
echo ""
echo "Final steps (Neovim/Spicetify) will be shown in a popup window after the first Hyprland launch."
echo ""
while true; do
    read -p "Reboot system now? (y/n): " yn
    case $yn in
        [Yy]* ) systemctl reboot; break;;
        [Nn]* ) exit;;
        * ) echo "Please answer yes or no.";;
    esac
done
