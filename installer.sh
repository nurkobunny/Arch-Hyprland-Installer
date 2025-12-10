#!/bin/bash
# installer.sh - Main script for Nurko Dots Hyprland installation (TTY)

# --- Variables ---
INSTALL_DIR=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" &> /dev/null && pwd)
SCRIPT_DIR="$INSTALL_DIR/scripts"
LOG_FILE="$INSTALL_DIR/installation.log"
DOTFILES_REPO="https://github.com/nurkobunny/DotsHyprland.git"
DOTFILES_DIR="$HOME/DotsHyprland"

# --- Setup Logging and Functions ---
# Create log file and clear previous log
> "$LOG_FILE"
echo "--- Nurko Dots Installation Log Start: $(date) ---" >> "$LOG_FILE"

# Source functions
if [ -f "$SCRIPT_DIR/functions.sh" ]; then
    source "$SCRIPT_DIR/functions.sh"
else
    echo "ERROR: Missing functions.sh file. Aborting." | tee -a "$LOG_FILE"
    exit 1
fi

# Set trap to ensure consistent logging on exit
trap "echo '--- Installation Log End: $(date) ---' >> '$LOG_FILE'" EXIT

# --- Execution Flow ---

header_message

# Check if running in TTY
if [ -n "$DISPLAY" ]; then
    error "Detected graphical session (\$DISPLAY). Please run this script from a clean TTY."
fi

# Interactive Warning and Theme Selection
initial_warning
SELECTED_THEME=$(select_theme)
echo "$SELECTED_THEME" > "$HOME/initial_theme_choice.txt"
log "Initial theme selected and saved: $SELECTED_THEME"

# 1. Run Prerequisites & Dependencies
source "$SCRIPT_DIR/step_1_prereq.sh" || error "Step 1 (Prerequisites) failed."

# 2. Run Configuration Setup
source "$SCRIPT_DIR/step_2_config_setup.sh" || error "Step 2 (Configuration Setup) failed."

# 3. Run Application Configurations
source "$SCRIPT_DIR/step_3_app_configs.sh" || error "Step 3 (App Configs) failed."

# 4. Run System & Visual Integration
source "$SCRIPT_DIR/step_4_system_viz.sh" || error "Step 4 (System Integration) failed."

# 5. Finalize Setup (Permissions, Copying Final Script)
log "STEP 5: Finalizing setup and setting permissions..."
chmod +x ~/.config/hypr/scripts/* || warn "Failed to set permissions on hypr/scripts."
chmod +x ~/.config/hypr/scripts/themesscript/* || warn "Failed to set permissions on hypr/scripts/themesscript."
chmod +x ~/.config/hypr/UserScripts/* || warn "Failed to set permissions on hypr/UserScripts."

# Copy the final graphical setup script
cp "$SCRIPT_DIR/final_setup.sh" "$HOME/final_setup_nurko_dots.sh"
chmod +x "$HOME/final_setup_nurko_dots.sh"
log "Final graphical setup script copied to $HOME/final_setup_nurko_dots.sh"


# --- TTY Conclusion ---
clear
echo "==================================================================" | tee -a "$LOG_FILE"
echo "          🎉 TTY INSTALLATION COMPLETE (Nurko Dots) 🎉" | tee -a "$LOG_FILE"
echo "==================================================================" | tee -a "$LOG_FILE"
echo "--- REQUIRED NEXT STEPS ---" | tee -a "$LOG_FILE"
echo "1. **IMPORTANT: Sudoers Configuration**" | tee -a "$LOG_FILE"
echo "   You must manually configure NOPASSWD for automated GRUB/SDDM (as per README):" | tee -a "$LOG_FILE"
echo "    export EDITOR=nano" | tee -a "$LOG_FILE"
echo "    sudo visudo" | tee -a "$LOG_FILE"
echo "   Add NOPASSWD lines for user $(whoami)." | tee -a "$LOG_FILE"
echo "2. **REBOOT** the system: \`sudo reboot\`" | tee -a "$LOG_FILE"
echo "3. After reboot, log in via SDDM (Hyprland session should be selected)." | tee -a "$LOG_FILE"
echo "4. **RUN THE FINAL SCRIPT** in a terminal (Kitty): \`./final_setup_nurko_dots.sh\`" | tee -a "$LOG_FILE"
echo "--- Log file saved to $LOG_FILE ---" | tee -a "$LOG_FILE"
