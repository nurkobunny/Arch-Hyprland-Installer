#!/bin/bash
# step_3_app_configs.sh - Step 3: Application Configurations (CRITICAL: Fixed copy logic)

log "STEP 3: Copying Application Configurations..."
COMPONENTS=$(cat "$HOME/selected_components.txt")

if [[ "$COMPONENTS" =~ "APP_CONFIGS" ]]; then
    
    log "Installing all application configurations (Selected)..."

    # A. Copy all dotfiles from the config directory to ~/.config/
    log "Copying all dotfiles from $DOTFILES_DIR/config to ~/.config/"
    mkdir -p ~/.config
    
    # --- CRITICAL FIX: Use reliable cp logic to copy contents ---
    # Удаляем старую папку hypr (если она была) и копируем ВСЁ содержимое config/
    rm -rf ~/.config/hypr # Удаляем, чтобы избежать конфликтов
    
    # Копируем содержимое $DOTFILES_DIR/config/ в ~/.config/ (включая скрытые файлы, кроме . и ..)
    cp -r "$DOTFILES_DIR/config/." ~/.config/ || error "Failed to copy configuration files to ~/.config."

    # B. Autostart Final Script (Crucial for post-reboot setup)
    AUTOSTART_FILE=~/.config/hypr/UserConfigs/Startup_Apps.conf
    AUTOSTART_LINE="exec-once = $HOME/final_setup_nurko_dots.sh"
    if [ ! -f "$AUTOSTART_FILE" ]; then touch "$AUTOSTART_FILE"; fi
    echo "$AUTOSTART_LINE" >> "$AUTOSTART_FILE"
    log "Added autostart line to Startup_Apps.conf: $AUTOSTART_LINE"

    # C. Set Execution Permissions (Ensures scripts run)
    log "Setting execution permissions for all scripts..."
    chmod +x ~/.config/hypr/scripts/* || warn "Failed to set permissions on hypr/scripts."
    chmod +x ~/.config/hypr/scripts/themesscript/* || warn "Failed to set permissions on hypr/scripts/themesscript."
    chmod +x ~/.config/hypr/UserScripts/* || warn "Failed to set permissions on hypr/UserScripts."
    
else
    log "Application Configurations skipped (APP_CONFIGS not selected)."
fi

log "Step 3 completed successfully."
