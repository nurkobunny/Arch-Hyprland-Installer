#!/bin/bash
# step_3_app_configs.sh - Step 3: Application Configurations (CRITICAL: Removed env_variables.conf creation)

log "STEP 3: Copying Application Configurations..."
COMPONENTS=$(cat "$HOME/selected_components.txt")

if [[ "$COMPONENTS" =~ "APP_CONFIGS" ]]; then
    
    log "Installing all application configurations (Selected)..."

    # A. Hyprland Configs
    rm -rf ~/.config/hypr 
    cp "$DOTFILES_DIR/config/hypr" -r ~/.config/ || error "Failed to copy Hyprland config."
    
    # B. Autostart Final Script (Crucial for post-reboot setup)
    AUTOSTART_FILE=~/.config/hypr/UserConfigs/Startup_Apps.conf
    AUTOSTART_LINE="exec-once = $HOME/final_setup_nurko_dots.sh"
    if [ ! -f "$AUTOSTART_FILE" ]; then touch "$AUTOSTART_FILE"; fi
    echo "$AUTOSTART_LINE" >> "$AUTOSTART_FILE"
    log "Added autostart line to Startup_Apps.conf: $AUTOSTART_LINE"

    # C. Other Application Configs 
    log "NOTE: Please ensure your full application configuration copying logic (VsCode, Rofi, Waybar, etc.) is placed here."
    
else
    log "Application Configurations skipped (APP_CONFIGS not selected)."
fi

log "Step 3 completed successfully."
