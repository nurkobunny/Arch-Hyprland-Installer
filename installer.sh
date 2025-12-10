#!/bin/bash
# installer.sh - Main script for Nurko Dots Hyprland installation (TTY)

# --- Variables ---
INSTALL_DIR=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" &> /dev/null && pwd)
SCRIPT_DIR="$INSTALL_DIR/scripts"
LOG_FILE="$INSTALL_DIR/installation.log"
DOTFILES_REPO="https://github.com/nurkobunny/DotsHyprland.git"
DOTFILES_DIR="$HOME/DotsHyprland"
USERNAME=$(whoami)

# --- Setup Logging and Functions ---
> "$LOG_FILE"
echo "--- Nurko Dots Installation Log Start: $(date) ---" >> "$LOG_FILE"

if [ -f "$SCRIPT_DIR/functions.sh" ]; then
    source "$SCRIPT_DIR/functions.sh"
else
    echo "ERROR: Missing functions.sh file. Aborting." | tee -a "$LOG_FILE"
    exit 1
fi
trap "echo '--- Installation Log End: $(date) ---' >> '$LOG_FILE'" EXIT

# --- Execution Flow ---

header_message

if [ -n "$DISPLAY" ]; then
    error "Detected graphical session (\$DISPLAY). Please run this script from a clean TTY."
fi

initial_warning

# --- Theme Setup (Non-interactive) ---
SELECTED_THEME="Catppuccin" # Hardcode the default theme
echo "$SELECTED_THEME" > "$HOME/initial_theme_choice.txt"
log "Default theme set to: $SELECTED_THEME (Non-interactive)."

# 1. Run Prerequisites & Dependencies (Includes NVIDIA choice, fixes SDDM packages)
source "$SCRIPT_DIR/step_1_prereq.sh" || error "Step 1 (Prerequisites) failed."

# 2. Run Configuration Setup (Includes Zsh path fix and Wayland environment for Zsh)
source "$SCRIPT_DIR/step_2_config_setup.sh" || error "Step 2 (Configuration Setup) failed."

# 3. Run Application Configurations (Includes critical Hyprland environment config)
source "$SCRIPT_DIR/step_3_app_configs.sh" || error "Step 3 (App Configs) failed."

# 4. Run System & Visual Integration (Includes automated sudoers and GRUB theme)
source "$SCRIPT_DIR/step_4_system_viz.sh" || error "Step 4 (System Integration) failed."

# 5. Finalize Setup (Permissions, Copying Final Script)
log "STEP 5: Finalizing setup and setting permissions..."
chmod +x ~/.config/hypr/scripts/* || warn "Failed to set permissions on hypr/scripts."
chmod +x ~/.config/hypr/scripts/themesscript/* || warn "Failed to set permissions on hypr/scripts/themesscript."
chmod +x ~/.config/hypr/UserScripts/* || warn "Failed to set permissions on hypr/UserScripts."

# Copy the final graphical setup script
cp "$SCRIPT_DIR/final_setup.sh" "$HOME/final_setup_nurko_dots.sh"
chmod +x "$HOME/final_setup_nurko_dots.sh"

# TTY Conclusion and Interactive Reboot
clear
echo "==================================================================" | tee -a "$LOG_FILE"
echo "          🎉 TTY INSTALLATION COMPLETE (Nurko Dots) 🎉" | tee -a "$LOG_FILE"
echo "==================================================================" | tee -a "$LOG_FILE"
echo "--- REQUIRED NEXT STEPS ---" | tee -a "$LOG_FILE"
echo "1. **SDDM will launch on reboot.** Log in with your user ($USERNAME) to the Hyprland session." | tee -a "$LOG_FILE"
echo "2. **The final setup script will run automatically** on first Hyprland launch." | tee -a "$LOG_FILE"
echo "3. Review the **MANUAL STEPS** displayed in the graphical warning window *after* logging in." | tee -a "$LOG_FILE"

confirm_reboot

exit 0
