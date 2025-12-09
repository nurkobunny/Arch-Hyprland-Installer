#!/bin/bash
source "$(dirname "$0")/header.sh"

DOTS_REPO="https://github.com/nurkobunny/DotsHyprland.git"
TEMP_DIR="$HOME/NurkoThemes_Temp"
git clone "$DOTS_REPO" "$TEMP_DIR" > /dev/null 2>&1

echo "${INFO} Installing themes and visuals..."

# Create directories
mkdir -p ~/.themes ~/.icons ~/Pictures

# Wallpapers
cp -r "$TEMP_DIR/wallpapers/"* ~/Pictures/
cp -r "$TEMP_DIR/fastfetch/"* ~/Pictures/

# GTK Themes
cp -r "$TEMP_DIR/themes/"* ~/.themes/

# Icons & Cursors
cp -r "$TEMP_DIR/icons/"* ~/.icons/
cd ~/.icons || exit
# Extract archives
for archive in *.tar.bz2; do
    [ -f "$archive" ] && tar -xf "$archive" && rm "$archive"
done

# Apply Settings
gsettings set org.gnome.desktop.interface font-name "JetBrains Mono Medium 13"
gsettings set org.gnome.desktop.interface cursor-theme "Nordic-cursors"

rm -rf "$TEMP_DIR"
echo "${OK} Themes installed."
