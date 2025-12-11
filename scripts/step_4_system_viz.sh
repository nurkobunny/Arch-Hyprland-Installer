#!/bin/bash
# step_4_system_viz.sh - Step 4: System & Visual Integration (CRITICAL: Fixed GRUB copy logic)

log "STEP 4: System and Visual Integration..."
COMPONENTS=$(cat "$HOME/selected_components.txt")

# A. Wallpapers (Conditional on APP_CONFIGS)
# ... (логика обоев без изменений) ...

# B. SDDM Theme (Conditional on SDDM_THEME)
# ... (логика SDDM без изменений) ...

# C. Sudoers configuration for NOPASSWD (Unconditional)
# ... (логика sudoers без изменений) ...

# D. GRUB Theme (Conditional on GRUB_THEME)
if [[ "$COMPONENTS" =~ "GRUB_THEME" ]]; then
    log "Installing GRUB Theme (Selected)..."
    
    # --- CRITICAL FIX: Create target directory and copy contents reliably ---
    # Создаем папку tartarus в директории тем GRUB
    sudo mkdir -p /usr/share/grub/themes/tartarus || warn "Failed to create GRUB theme directory."
    
    # Копируем содержимое папки grub/ в созданную папку tartarus
    sudo cp -r "$DOTFILES_DIR/grub/." /usr/share/grub/themes/tartarus/ || error "Failed to copy GRUB theme files."

    # Set theme path in grub config
    sudo sed -i 's|^#GRUB_THEME=.*|GRUB_THEME="/boot/grub/themes/tartarus/theme.txt"|' /etc/default/grub || warn "Failed to set GRUB_THEME."
    
    # Apply permissions and update grub
    sudo chmod -R 755 /usr/share/grub/themes/tartarus || warn "Failed to set permissions on GRUB theme directory."
    sudo grub-mkconfig -o /boot/grub/grub.cfg || warn "Failed to run 'grub-mkconfig'."
else
    log "GRUB Theme skipped."
fi

log "Step 4 completed successfully."
