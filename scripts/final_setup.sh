#!/bin/bash
# final_setup.sh - Script runs once upon first Hyprland graphical launch.

# --- Variables ---
LOG_FILE="$HOME/installation.log"
INSTALL_DIR=$(cd -- "$(dirname -- "$0")" &> /dev/null && pwd)
DOTFILES_DIR="$HOME/DotsHyprland"
USERNAME=$(whoami)
AUTOSTART_FILE="$HOME/.config/hypr/UserConfigs/Startup_Apps.conf"
SCRIPT_NAME=$(basename "$0")
COMPONENTS_FILE="$HOME/selected_components.txt"

# Simple logging function for graphical session
log_final() {
    echo -e "[FINAL SETUP] $1" >> "$LOG_FILE"
}

# 1. Check if the script should run (based on APP_CONFIGS component selection)
if [ ! -f "$COMPONENTS_FILE" ] || ! grep -q "APP_CONFIGS" "$COMPONENTS_FILE"; then
    log_final "APP_CONFIGS component was not selected. Skipping final setup and cleaning autostart."
    # Clean autostart even if skipped (for safety)
    sed -i "/exec-once = $HOME\/$SCRIPT_NAME/d" "$AUTOSTART_FILE"
    exit 0
fi


# 2. Check if already run (using a simple flag file)
if [ -f "$HOME/.nurko_dots_setup_completed" ]; then
    log_final "Setup already completed. Cleaning autostart and exiting."
    # In case the flag exists, but autostart was not cleaned
    sed -i "/exec-once = $HOME\/$SCRIPT_NAME/d" "$AUTOSTART_FILE"
    exit 0
fi

log_final "Starting final graphical setup (first run)..."

# 3. Apply default theme and run post-install tasks
DEFAULT_THEME=$(cat "$HOME/initial_theme_choice.txt" 2>/dev/null || echo "Catppuccin")

log_final "Running initial theme script for $DEFAULT_THEME."
# Call the theme application script (assuming it exists in dotfiles)
if [ -x "$DOTFILES_DIR/config/hypr/scripts/themesscript/themecall.sh" ]; then
    "$DOTFILES_DIR/config/hypr/scripts/themesscript/themecall.sh" "$DEFAULT_THEME"
else
    log_final "WARNING: themecall.sh script not found/executable. Skipping theme application."
fi

# 4. Neovim Plugin Setup
log_final "Installing Neovim plugins..."
# Launch nvim using kitty to see progress, but run in background
kitty -e nvim --headless +PackerSync +qa &

# 5. Cleanup and Mark as Complete
log_final "Cleanup: Removing autostart line from Startup_Apps.conf."
# Remove the autostart line so the script does not run again
sed -i "/exec-once = $HOME\/$SCRIPT_NAME/d" "$AUTOSTART_FILE"

log_final "Cleanup: Creating completion flag."
touch "$HOME/.nurko_dots_setup_completed"

log_final "Cleanup: Removing temporary files."
rm -f "$HOME/initial_theme_choice.txt" 
rm -f "$HOME/gpu_choice.txt"
# Remove the script itself
rm -f "$HOME/$SCRIPT_NAME"

# 6. Final User Notification (NOW IN ENGLISH)
log_final "Final instructions shown to user."

(
echo "=========================================================="
echo "    ✨ NURKO DOTS INSTALLATION COMPLETE! (Hyprland) ✨"
echo "=========================================================="
echo "1. Default theme ($DEFAULT_THEME) has been applied."
echo "2. Neovim plugins are installing in the background."
echo " "
echo "--- REQUIRED MANUAL STEPS: ---"
echo "   - Set the Gnome Keyring password when prompted for application authorization (Spotify, VSCode)."
echo "   - Complete VsCode/Spotify setup if required."
echo "   - Press Win + R (Rofi) to launch applications."
echo " "
echo "=========================================================="
echo "You may close this window. The script will not run again."
echo "=========================================================="
read -r -p "Press ENTER to close..."
) | kitty --title "NURKO DOTS SETUP COMPLETE" -

exit 0
