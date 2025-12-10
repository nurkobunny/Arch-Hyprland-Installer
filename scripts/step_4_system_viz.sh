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

# --- NEW: Sudoers configuration for NOPASSWD ---
log "Creating automatic sudoers file for NOPASSWD operations..."
SUDOERS_FILE="/etc/sudoers.d/99-nurko_dots_nopasswd"
# The NOPASSWD lines are required for the following commands to run without user input:
echo "$USERNAME ALL=(ALL) NOPASSWD: /usr/bin/sed *, /etc/default/grub" | sudo tee "$SUDOERS_FILE" > /dev/null
echo "$USERNAME ALL=(ALL) NOPASSWD: /usr/bin/sed *, /usr/share/sddm/themes/simple_sddm_2/metadata.desktop" | sudo tee -a "$SUDOERS_FILE" > /dev/null
echo "$USERNAME ALL=(ALL) NOPASSWD: /usr/bin/grub-mkconfig *" | sudo tee -a "$SUDOERS_FILE" > /dev/null
echo "$USERNAME ALL=(ALL) NOPASSWD: /usr/bin/sed *, /boot/grub/themes" | sudo tee -a "$SUDOERS_FILE" > /dev/null
echo "$USERNAME ALL=(ALL) NOPASSWD: /bin/cp" | sudo tee -a "$SUDOERS_FILE" > /dev/null
sudo chmod 0440 "$SUDOERS_FILE" || warn "Failed to set correct permissions on $SUDOERS_FILE."
log "Sudoers NOPASSWD configuration created at $SUDOERS_FILE."
# --- END NEW Sudoers configuration ---

# C. GRUB Theme (Now runs automatically thanks to NOPASSWD)
log "Installing GRUB theme and configuring..."
sudo cp "$DOTFILES_DIR/grub/"* -r /usr/share/grub/themes/ || error "Failed to copy GRUB theme."
sudo sed -i 's|^#GRUB_THEME=.*|GRUB_THEME="/boot/grub/themes/tartarus/theme.txt"|' /etc/default/grub || warn "Failed to set GRUB_THEME in /etc/default/grub."
sudo chmod -R 755 /usr/share/grub/themes/*
sudo grub-mkconfig -o /boot/grub/grub.cfg || warn "Failed to run 'grub-mkconfig'. Check the sudoers file."

log "Step 4 completed successfully."
