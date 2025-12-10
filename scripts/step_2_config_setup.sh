#!/bin/bash
# step_2_config_setup.sh - Step 2: Clone Repository and Basic Configuration Setup (Fixed Zsh path)

log "STEP 2: Cloning Repository and Basic Configuration Setup..."

# A. Clone repository
if [ -d "$DOTFILES_DIR" ]; then rm -rf "$DOTFILES_DIR"; fi
git clone "$DOTFILES_REPO" "$DOTFILES_DIR" || error "Failed to clone repository."

# B. Zsh/p10k Setup (CRITICAL FIX for Zsh Path)
log "Configuring Zsh/Powerlevel10k..."
mkdir -p ~/.oh-my-zsh
cp "$DOTFILES_DIR/zsh/oh-my-zsh/"* -r ~/.oh-my-zsh || error "Failed to copy Oh My Zsh files."
cp "$DOTFILES_DIR/zsh/zshrc" ~/.zshrc || error "Failed to copy .zshrc."

# CRITICAL FIX: Ensure correct path and filename for powerlevel10k
sed -i '/powerlevel/d' ~/.zshrc # Remove any old or incorrect line
echo 'source /usr/share/zsh-theme-powerlevel10k/powerlevel10k.zsh-theme' >>~/.zshrc 
cp "$DOTFILES_DIR/zsh/p10k.zsh" ~/.p10k.zsh || error "Failed to copy .p10k.zsh."

# Add General Wayland Environment Variables to Zsh (for manual TTY launch compatibility)
log "Adding essential Wayland environment variables to .zshrc..."
echo -e "\n# Wayland Environment Variables (Essential for Hyprland/Qt compatibility)" >>~/.zshrc
echo 'export QT_QPA_PLATFORM="wayland;xcb"' >>~/.zshrc
echo 'export LIBVA_DRIVER_NAME="mesa"' >>~/.zshrc 
# (chsh omitted for brevity, assuming working)

# C. GTK Themes, Icons, Font and Cursor
log "Installing GTK Themes and Icons..."
mkdir -p ~/.themes && mkdir -p ~/.icons
cp "$DOTFILES_DIR/themes/"* -r ~/.themes || error "Failed to copy themes."
cp "$DOTFILES_DIR/icons/"* -r ~/.icons || error "Failed to copy icons."

log "Step 2 completed successfully."
