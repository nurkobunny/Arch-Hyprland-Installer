#!/bin/bash
# step_4_system_viz.sh - Step 4: System & Visual Integration (Automated sudoers)

log "STEP 4: System and Visual Integration..."

# A. Wallpapers
mkdir -p ~/Pictures
cp "$DOTFILES_DIR/wallpapers/" -r ~/Pictures/ || warn "Failed to copy wallpapers."

# B. SDDM Theme
sudo cp "$DOTFILES_DIR/sddm/simple_sddm_2/" -r /usr/share/sddm/themes/ || error "Failed to copy SDDM theme."
sudo cp "$DOTFILES_DIR/sddm/sddm.conf" -r /etc/ || error "Failed to copy sddm.conf."
sudo systemctl enable sddm || warn "Failed to enable SDDM."

# C. Sudoers configuration for NOPASSWD (CRITICAL FIX)
log "Creating automatic sudoers file for NOPASSWD operations..."
SUDOERS_FILE="/etc/sudoers.d/99-nurko_dots_nopasswd"
# Grant NOPASSWD for common admin tasks (reboot, grub, cp, sed)
echo "$USERNAME ALL=(ALL) NOPASSWD: /usr/bin/sed *, /etc/default/grub" | sudo tee "$SUDOERS_FILE" > /dev/null
echo "$USERNAME ALL=(ALL) NOPASSWD: /usr/bin/grub-mkconfig *" | sudo tee -a "$SUDOERS_FILE" > /dev/null
echo "$USERNAME ALL=(ALL) NOPASSWD: /bin/cp" | sudo tee -a "$SUDOERS_FILE" > /dev/null
echo "$USERNAME ALL=(ALL) NOPASSWD: /usr/bin/reboot, /usr/sbin/reboot" | sudo tee -a "$SUDOERS_FILE" > /dev/null
echo "$USERNAME ALL=(ALL) NOPASSWD: /usr/bin/systemctl reboot, /usr/bin/systemctl enable sddm" | sudo tee -a "$SUDOERS_FILE" > /dev/null
sudo chmod 0440 "$SUDOERS_FILE" || warn "Failed to set correct permissions on $SUDOERS_FILE."
log "Sudoers NOPASSWD configuration created."

# D. GRUB Theme (Relies on NOPASSWD)
sudo cp "$DOTFILES_DIR/grub/"* -r /usr/share/grub/themes/ || error "Failed to copy GRUB theme."
sudo sed -i 's|^#GRUB_THEME=.*|GRUB_THEME="/boot/grub/themes/tartarus/theme.txt"|' /etc/default/grub || warn "Failed to set GRUB_THEME."
sudo grub-mkconfig -o /boot/grub/grub.cfg || warn "Failed to run 'grub-mkconfig'."

log "Step 4 completed successfully."
