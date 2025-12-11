#!/bin/bash
# step_4_system_viz.sh - Step 4: System & Visual Integration (Automated sudoers, theme conditional)

log "STEP 4: System and Visual Integration..."
COMPONENTS=$(cat "$HOME/selected_components.txt")

# A. Wallpapers (Conditional on APP_CONFIGS)
if [[ "$COMPONENTS" =~ "APP_CONFIGS" ]]; then
    log "Copying Wallpapers (Selected)..."
    mkdir -p ~/Pictures
    cp "$DOTFILES_DIR/wallpapers/" -r ~/Pictures/ || warn "Failed to copy wallpapers."
else
    log "Wallpapers skipped."
fi

# B. SDDM Theme (Conditional on SDDM_THEME)
if [[ "$COMPONENTS" =~ "SDDM_THEME" ]]; then
    log "Installing SDDM Theme (Selected)..."
    # Ensure SDDM package is installed (it's in step 1, but this check provides safety)
    if ! command -v sddm &> /dev/null; then
        warn "SDDM package not found. Skipping theme installation."
    else
        # CRITICAL FIX: Use 'cp -r' to copy the theme folder
        sudo cp "$DOTFILES_DIR/sddm/simple_sddm_2/" -r /usr/share/sddm/themes/ || error "Failed to copy SDDM theme."
        sudo cp "$DOTFILES_DIR/sddm/sddm.conf" -r /etc/ || error "Failed to copy sddm.conf."
        sudo systemctl enable sddm || warn "Failed to enable SDDM."
    fi
else
    log "SDDM Theme skipped."
fi

# C. Sudoers configuration for NOPASSWD (CRITICAL FIX - Unconditional for system maintenance)
log "Creating automatic sudoers file for NOPASSWD operations..."
SUDOERS_FILE="/etc/sudoers.d/99-nurko_dots_nopasswd"
# Grant NOPASSWD for common admin tasks (reboot, grub, cp, sed, systemctl)
echo "$USERNAME ALL=(ALL) NOPASSWD: /usr/bin/sed *, /etc/default/grub" | sudo tee "$SUDOERS_FILE" > /dev/null
echo "$USERNAME ALL=(ALL) NOPASSWD: /usr/bin/grub-mkconfig *" | sudo tee -a "$SUDOERS_FILE" > /dev/null
echo "$USERNAME ALL=(ALL) NOPASSWD: /bin/cp" | sudo tee -a "$SUDOERS_FILE" > /dev/null
echo "$USERNAME ALL=(ALL) NOPASSWD: /usr/bin/reboot, /usr/sbin/reboot" | sudo tee -a "$SUDOERS_FILE" > /dev/null
echo "$USERNAME ALL=(ALL) NOPASSWD: /usr/bin/systemctl reboot, /usr/bin/systemctl enable sddm, /usr/bin/systemctl start sddm" | sudo tee -a "$SUDOERS_FILE" > /dev/null
sudo chmod 0440 "$SUDOERS_FILE" || warn "Failed to set correct permissions on $SUDOERS_FILE."
log "Sudoers NOPASSWD configuration created."

# D. GRUB Theme (Conditional on GRUB_THEME)
if [[ "$COMPONENTS" =~ "GRUB_THEME" ]]; then
    log "Installing GRUB Theme (Selected)..."
    sudo cp "$DOTFILES_DIR/grub/"* -r /usr/share/grub/themes/ || error "Failed to copy GRUB theme."
    sudo sed -i 's|^#GRUB_THEME=.*|GRUB_THEME="/boot/grub/themes/tartarus/theme.txt"|' /etc/default/grub || warn "Failed to set GRUB_THEME."
    sudo grub-mkconfig -o /boot/grub/grub.cfg || warn "Failed to run 'grub-mkconfig'."
else
    log "GRUB Theme skipped."
fi

log "Step 4 completed successfully."
