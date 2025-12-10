#!/bin/bash
# final_setup.sh - Final setup script for Nurko Dots (Run inside Hyprland)

# --- Variables ---
DOTFILES_DIR="$HOME/DotsHyprland"
THEME_CHOICE_FILE="$HOME/initial_theme_choice.txt"
USERNAME=$(whoami)

# --- Logging Functions (Using notify-send for graphical feedback) ---
notify_log() {
    if command -v notify-send &> /dev/null; then
        notify-send "Nurko Dots Setup" "$1" -i info
    fi
    echo -e "\n[INFO] $1"
}

notify_warn() {
    if command -v notify-send &> /dev/null; then
        notify-send "Nurko Dots Setup (Warning)" "$1" -i warning
    fi
    echo -e "\n[WARN] $1"
}

# --- Core Setup ---

notify_log "Starting final setup for Nurko Dots in Hyprland..."

# A. Hyprland Configs Reload
hyprctl reload || notify_warn "Failed to reload Hyprland config."

# B. GTK Themes/Cursor fix (gsettings needs graphical environment)
notify_log "Setting GTK font and cursor..."
gsettings set org.gnome.desktop.interface font-name "JetBrains Mono Medium 13" 2>/dev/null || notify_warn "Failed to set GTK Font."
gsettings set org.gnome.desktop.interface cursor-theme "Nordic-cursors" 2>/dev/null || notify_warn "Failed to set GTK Cursor."

# C. Neovim PlugInstall
notify_log "Installing Neovim plugins (:PlugInstall)..."
kitty nvim -c "PlugInstall" -c "qa" || notify_warn "Failed to run Neovim PlugInstall. Try running 'nvim' and then ':PlugInstall' manually."

# D. Apply Initial Theme
if [ -f "$THEME_CHOICE_FILE" ]; then
    SELECTED_THEME=$(cat "$THEME_CHOICE_FILE")
    notify_log "Applying initial theme: $SELECTED_THEME"
    # Execute the specific theme script based on the choice file
    find "$HOME/.config/hypr/scripts/themesscript/" -name "*$SELECTED_THEME*" -exec {} \;
    rm "$THEME_CHOICE_FILE"
else
    notify_warn "Initial theme choice file not found. Apply theme manually using SUPER + T."
fi

# E. Spicetify Setup
notify_log "Starting Spotify to create necessary directories for Spicetify..."
spotify-launcher & #
sleep 5
pkill spotify-launcher || true
notify_log "Applying Spicetify theme and enabling devtools..."
spicetify backup apply enable-devtools
spicetify apply || notify_warn "Failed to apply Spicetify. Run 'spicetify apply' manually after setting up extensions."

# F. Firefox UserChrome Setup
notify_log "Configuring Firefox UserChrome..."
PROFILE=$(ls ~/.mozilla/firefox/ | grep default-release | head -n 1)
if [ -n "$PROFILE" ]; then
    cp -r "$DOTFILES_DIR/firefox/"* ~/.mozilla/firefox/$PROFILE/
    notify_log "Firefox files copied to profile: $PROFILE"
else
    notify_warn "Could not find Firefox profile. Run Firefox once and execute the manual step below."
fi

# --- Manual Steps (Cannot be fully automated) ---

notify_log "--- ⚠️ MANUAL INTERVENTION REQUIRED (Nurko Dots) ⚠️ ---"

MANUAL_STEPS="1. **Obsidian Config (Section 3.E):** Copy the config to your vault's location. (Replace /path/to/your/vault/)\n   \$ cp $DOTFILES_DIR/obsidian/* -r /path/to/your/obsidian/vault/.obsidian\n\n2. **Spicetify Manual (Section 3.C):** Open Spotify, install extensions (Auto Skip Videos, adblockify, Spicy Lyrics). Go to Settings (Ctrl+P), enable Static Background/Hide Now Playing View Dynamic Background, set Static Background Type to 'color', and run 'spicetify apply' in terminal.\n\n3. **Firefox Custom New Page (Section 3.G):** Launch Firefox, enable the **Custom New Page** extension, and set its **New Tab Url** to \`http://localhost:8000/\`."

# Show manual steps in a graphical box
if command -v zenity &> /dev/null; then
    zenity --warning --title="Nurko Dots - Final Manual Steps" --text="$MANUAL_STEPS"
else
    # Fallback to echo if zenity is missing
    echo -e "$MANUAL_STEPS"
fi

# Clean up
rm "$HOME/final_setup_nurko_dots.sh"

notify_log "🎉 ALL AUTOMATIC SETUP COMPLETE! Use SUPER + T to change themes. 🎉"
