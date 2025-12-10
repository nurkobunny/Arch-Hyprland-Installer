# step_4_system_viz.sh - Step 4: System and Visual Integration

log "STEP 4: System and Visual Integration (Wallpapers, SDDM, GRUB)..."

# A. Wallpapers
log "Copying wallpapers and fastfetch logo..."
mkdir -p ~/Pictures
cp "$DOTFILES_DIR/wallpapers/" -r ~/Pictures/ || warn "Failed to copy wallpapers."
cp "$DOTFILES_DIR/fastfetch/" -r ~/Pictures/ || warn "Failed to copy fastfetch logo."

# B. SDDM Theme
log "Installing SDDM theme..."
sudo cp "$DOTFILES_DIR/sddm/simple_sddm_2/" -r /usr/share/sddm/themes/ || error "Failed to copy SDDM theme."
sudo cp "$DOTFILES_DIR/sddm/sddm.conf" -r /etc/ || error "Failed to copy sddm.conf."
sudo systemctl enable sddm || warn "Failed to enable SDDM. Enable it manually: 'sudo systemctl enable sddm'."

# C. GRUB Theme
log "Installing GRUB theme and configuring..."
sudo cp "$DOTFILES_DIR/grub/"* -r /usr/share/grub/themes/ || error "Failed to copy GRUB theme."
# This command requires NOPASSWD in sudoers
sudo sed -i 's|^#GRUB_THEME=.*|GRUB_THEME="/boot/grub/themes/tartarus/theme.txt"|' /etc/default/grub || warn "Failed to set GRUB_THEME in /etc/default/grub."
sudo chmod -R 755 /usr/share/grub/themes/*
# This command requires NOPASSWD in sudoers
sudo grub-mkconfig -o /boot/grub/grub.cfg || warn "Failed to run 'grub-mkconfig'. Ensure NOPASSWD is set in sudoers or run it manually."

log "Step 4 completed successfully."
