#!/bin/bash
source "$(dirname "$0")/header.sh"

DOTS_REPO="https://github.com/nurkobunny/DotsHyprland.git"
TEMP_DIR="$HOME/NurkoDots_Temp"
AUTOSTART_FILE="$HOME/.config/hypr/hyprland.conf"

echo "${INFO} Configuring Dotfiles..."

# 1. Clone Repo (Existing Logic)
if [ -d "$TEMP_DIR" ]; then rm -rf "$TEMP_DIR"; fi
echo "${NOTE} Cloning repository..."
git clone "$DOTS_REPO" "$TEMP_DIR"

# 2. ZSH Configuration (Existing Logic)
echo "${NOTE} Setting up ZSH..."
mkdir -p ~/.oh-my-zsh
cp -r "$TEMP_DIR/zsh/oh-my-zsh/"* ~/.oh-my-zsh/ 2>/dev/null
cp "$TEMP_DIR/zsh/zshrc" ~/.zshrc
cp "$TEMP_DIR/zsh/p10k.zsh" ~/.p10k.zsh
sudo chsh -s /usr/bin/zsh "$USER"

# 3. Hyprland & App Configs (Existing Logic)
echo "${NOTE} Copying configurations (Hyprland, Waybar, etc)..."
if [ -d ~/.config/hypr ]; then mv ~/.config/hypr ~/.config/hypr.bak; fi

mkdir -p ~/.config
cp -r "$TEMP_DIR/config/hypr" ~/.config/
cp -r "$TEMP_DIR/config/"{cava,fastfetch,kitty,Kvantum,micro,nvim,nwg-look,rofi,swaync,swappy,Thunar,wallust,waybar} ~/.config/ 2>/dev/null

# ... (Other application configs like VSCode, Spicetify, Firefox CSS) ...

# Set Executable Permissions (Existing Logic)
chmod +x ~/.config/hypr/scripts/*
chmod +x ~/.config/hypr/UserScripts/*

# =========================================================================
# 4. NEW: CREATE POST-INSTALL NOTIFIER SCRIPT
# =========================================================================
echo "${NOTE} Creating post-installation notifier script..."
NOTIFIER_SCRIPT="$HOME/.config/hypr/UserScripts/post_install_notifier.sh"
mkdir -p "$(dirname "$NOTIFIER_SCRIPT")"

cat <<'EOF' > "$NOTIFIER_SCRIPT"
#!/bin/bash

# Flag file to run script only once
FLAG_FILE="$HOME/.config/hypr/.post_install_done"

# Check if flag file exists
if [ -f "$FLAG_FILE" ]; then
    exit 0
fi

# Message to display in the YAD window
YAD_MESSAGE="
# 🚀 Post-Installation Steps for NurkoDots

Welcome to Hyprland! To complete your setup, please perform these manual steps:

## 1. Neovim Setup
Open Neovim and run the command below to install all plugins:
\`\`\`bash
:PlugInstall
\`\`\`
*(Wait for the installation to finish and then quit Nvim)*

## 2. Spicetify Setup
Configure Spotify to use the new theme:
1. Apply the theme/extensions:
   \`\`\`bash
   spicetify apply enable-devtools
   \`\`\`
2. Restart Spotify.

"

# Display the YAD window
yad --title="NurkoDots - Final Setup Steps" \
    --text-info \
    --text="$YAD_MESSAGE" \
    --width=600 \
    --height=400 \
    --center \
    --button="DONE:0"

# Create flag file after closing the window so it doesn't run again
touch "$FLAG_FILE"

exit 0
EOF

# Ensure the script is executable
chmod +x "$NOTIFIER_SCRIPT"

# 5. NEW: ADD NOTIFIER TO HYPRLAND AUTOSTART
if [ -f "$AUTOSTART_FILE" ]; then
    echo "${NOTE} Adding notifier script to Hyprland autostart..."
    # Add a line to execute the notifier script on Hyprland startup (exec-once ensures it runs only once per session)
    echo "exec-once = $NOTIFIER_SCRIPT" >> "$AUTOSTART_FILE"
fi

# Cleanup (Existing Logic)
rm -rf "$TEMP_DIR"
echo "${OK} Dotfiles configuration applied."
