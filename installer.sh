#!/bin/bash
# installer.sh - Main script for Nurko Dots Hyprland installation (TTY) (FINAL: WHIPTAIL)

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

# --- CRITICAL: Check and Install whiptail ---
if ! command -v whiptail &> /dev/null; then
    log "whiptail utility not found. Installing now..."
    sudo pacman -S --noconfirm --needed whiptail || error "Failed to install whiptail utility."
fi

# --- NEW: Component Selection (whiptail --checklist) ---
log "Starting whiptail component selection menu..."
COMPONENTS=$(whiptail --backtitle "Nurko Dots Hyprland Installer" \
    --title "SELECT INSTALLATION COMPONENTS" \
    --checklist "Choose which parts of the setup to install:" 20 70 8 \
    "HYPRLAND" "Hyprland and Core Dependencies (REQUIRED)" ON \
    "ZSH_SETUP" "Zsh/Powerlevel10k Configuration" ON \
    "APP_CONFIGS" "All Application Configurations (Rofi, Kitty, Waybar, etc.)" ON \
    "SDDM_THEME" "SDDM Login Manager Theme" ON \
    "GRUB_THEME" "GRUB Bootloader Theme (Requires GRUB to be installed)" ON \
    3>&1 1>&2 2>&3)

exit_status=$?
clear

if [ $exit_status -eq 1 ]; then
    error "Component selection cancelled by user."
fi

log "Selected components: $COMPONENTS"
echo "$COMPONENTS" > "$HOME/selected_components.txt" 

# Проверяем, что Hyprland выбран.
if [[ ! "$COMPONENTS" =~ "HYPRLAND" ]]; then
    error "Hyprland/Core Dependencies must be selected to proceed."
fi

# --- Theme Setup (Non-interactive) ---
SELECTED_THEME="Catppuccin" # Hardcode the default theme
echo "$SELECTED_THEME" > "$HOME/initial_theme_choice.txt"
log "Default theme set to: $SELECTED_THEME (Non-interactive)."

# --- CRITICAL: General GPU Selection and saving choice ---
GPU_CHOICE=$(select_gpu_type) 
echo "$GPU_CHOICE" > "$HOME/gpu_choice.txt" 
log "GPU choice saved to file: $GPU_CHOICE"

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

if [[ "$COMPONENTS" =~ "APP_CONFIGS" ]]; then
    chmod +x ~/.config/hypr/scripts/* || warn "Failed to set permissions on hypr/scripts."
    chmod +x ~/.config/hypr/scripts/themesscript/* || warn "Failed to set permissions on hypr/scripts/themesscript."
    chmod +x ~/.config/hypr/UserScripts/* || warn "Failed to set permissions on hypr/UserScripts."

    # Copy the final graphical setup script
    cp "$SCRIPT_DIR/final_setup.sh" "$HOME/final_setup_nurko_dots.sh"
    chmod +x "$HOME/final_setup_nurko_dots.sh"
else
    log "Final setup/script permissions skipped (APP_CONFIGS not selected)."
fi

# TTY Conclusion and Interactive Reboot
clear
echo "==================================================================" | tee -a "$LOG_FILE"
echo "          🎉 TTY INSTALLATION COMPLETE (Nurko Dots) 🎉" | tee -a "$LOG_FILE"
echo "==================================================================" | tee -a "$LOG_FILE"
echo "--- REQUIRED NEXT STEPS ---" | tee -a "$LOG_FILE"
echo "1. **SDDM will launch on reboot.** Log in with your user ($USERNAME) to the Hyprland session." | tee -a "$LOG_FILE"
echo "2. **The final setup script will run automatically** on first Hyprland launch (if APP_CONFIGS was selected)." | tee -a "$LOG_FILE"
echo "3. Review the **MANUAL STEPS** displayed in the graphical warning window *after* logging in." | tee -a "$LOG_FILE"

confirm_reboot

exit 0
