# step_2_config_setup.sh - Step 2: Clone Repository and Basic Configuration Setup

log "STEP 2: Cloning Repository and Basic Configuration Setup..."

# A. Clone Repository
log "Cloning Nurko Dots repository..."
if [ -d "$DOTFILES_DIR" ]; then
    warn "Dotfiles directory exists. Removing and recloning."
    rm -rf "$DOTFILES_DIR"
fi
git clone "$DOTFILES_REPO" "$DOTFILES_DIR" || error "Failed to clone Nurko Dots repository."

# B. Zsh/p10k Setup
log "Configuring Zsh/Powerlevel10k..."
mkdir -p ~/.oh-my-zsh
cp "$DOTFILES_DIR/zsh/oh-my-zsh/"* -r ~/.oh-my-zsh || error "Failed to copy Oh My Zsh files."
# p10k already installed via yay
cp "$DOTFILES_DIR/zsh/zshrc" ~/.zshrc || error "Failed to copy .zshrc."

# FIX: Ensure correct path and filename for powerlevel10k
# The correct line should reference the theme file installed by the yay package zsh-theme-powerlevel10k-git
echo 'source /usr/share/zsh-theme-powerlevel10k/powerlevel10k.zsh-theme' >>~/.zshrc 

cp "$DOTFILES_DIR/zsh/p10k.zsh" ~/.p10k.zsh || error "Failed to copy .p10k.zsh."
# Plugins
ZSH_CUSTOM=${ZSH_CUSTOM:-~/.oh-my-zsh/custom}
git clone https://github.com/zsh-users/zsh-syntax-highlighting.git ${ZSH_CUSTOM}/plugins/zsh-syntax-highlighting || warn "Failed to clone syntax-highlighting plugin."
git clone https://github.com/zsh-users/zsh-autosuggestions ${ZSH_CUSTOM}/plugins/zsh-autosuggestions || warn "Failed to clone autosuggestions plugin."
chsh -s /usr/bin/zsh || warn "Failed to automatically change shell to Zsh. Do it manually: 'chsh -s /usr/bin/zsh'."

# C. GTK Themes, Icons, Font and Cursor
log "Installing GTK Themes and Icons..."
mkdir -p ~/.themes
mkdir -p ~/.icons
cp "$DOTFILES_DIR/themes/"* -r ~/.themes || error "Failed to copy themes."
cp "$DOTFILES_DIR/icons/"* -r ~/.icons || error "Failed to copy icons."

cd ~/.icons
tar -xjf Nordic-cursors.tar.bz2 || warn "Could not unpack Nordic-cursors."
tar -xjf Catppuccin-SE.tar.bz2 || warn "Could not unpack Catppuccin-SE."
tar -xjf TokyoNight-SE.tar.bz2 || warn "Could not unpack TokyoNight-SE."
rm -f *.tar.bz2
cd "$HOME"

warn "Cannot set GTK font and cursor theme from TTY (gsettings will fail). This will be attempted after first Hyprland launch."
log "Step 2 completed successfully."
