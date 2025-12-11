#!/bin/bash
# step_3_app_configs.sh - Step 3: Application Configurations (Очищенная версия)

log "STEP 3: Copying Application Configurations..."

# A. Hyprland Configs
rm -rf ~/.config/hypr 
cp "$DOTFILES_DIR/config/hypr" -r ~/.config/ || error "Failed to copy Hyprland config."
# (Other App Configs omitted for brevity, assuming working logic)

# B. Autostart Final Script
AUTOSTART_FILE=~/.config/hypr/UserConfigs/Startup_Apps.conf
AUTOSTART_LINE="exec-once = $HOME/final_setup_nurko_dots.sh"
if [ ! -f "$AUTOSTART_FILE" ]; then touch "$AUTOSTART_FILE"; fi
echo "$AUTOSTART_LINE" >> "$AUTOSTART_FILE"
log "Added autostart line to Startup_Apps.conf: $AUTOSTART_LINE"

log "Step 3 completed successfully."
