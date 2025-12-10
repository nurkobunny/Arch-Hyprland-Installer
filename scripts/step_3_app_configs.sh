# step_3_app_configs.sh - Step 3: Application Configurations

log "STEP 3: Copying Application Configurations..."

# A. Hyprland Configs
log "Copying Hyprland configuration..."
rm -rf ~/.config/hypr
cp "$DOTFILES_DIR/config/hypr" -r ~/.config/ || error "Failed to copy Hyprland config."
warn "Hyprland reload will happen after first launch."

# B. VsCode (Code - OSS) Configs
log "Copying VsCode (Code - OSS) configuration..."
mkdir -p ~/.vscode-oss
cp "$DOTFILES_DIR/vscode-oss/"* -r ~/.vscode-oss || error "Failed to copy VsCode-oss files."
mkdir -p ~/.config/Code\ -\ OSS/User/
cp "$DOTFILES_DIR/config/Code - OSS/"* -r ~/.config/Code\ -\ OSS/User/ || error "Failed to copy Code - OSS config."

# C. Spicetify (Spotify Theme)
log "Copying Spicetify configuration files..."
cp "$DOTFILES_DIR/config/spicetify" -rf ~/.config/ || error "Failed to copy Spicetify config."
warn "Spicetify setup requires running Spotify first. Final setup will be done in the graphical environment."

# D. Other Application Configs
log "Copying other application configurations..."
# Remove existing config folders
rm -rf ~/.config/{cava,fastfetch,gtk-3.0,gtk-4.0,kitty,Kvantum,micro,nvim,nwg-look,rofi,swaync,swappy,Thunar,wallust,waybar}
# Copy new configurations
cp "$DOTFILES_DIR/config/"{cava,fastfetch,gtk-3.0,gtk-4.0,kitty,Kvantum,micro,nvim,nwg-look,rofi,swaync,swappy,Thunar,wallust,firefox-themes,firefox-custom-addons,waybar} -r ~/.config || error "Failed to copy other app configs."

# E. Obsidian Config
warn "Obsidian configuration requires knowing your vault path. This step must be done manually after first launch (Section 3.E)."

# F. Neovim
log "Installing Neovim Plugin Manager (vim-plug)..."
sh -c 'curl -fLo "${XDG_DATA_HOME:-$HOME/.local/share}"/nvim/site/autoload/plug.vim --create-dirs \
       https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim' || error "Failed to install vim-plug."
warn "After first launch, open Neovim and run ':PlugInstall' in command mode."

# G. Firefox UserChrome
warn "Firefox UserChrome setup requires finding the profile name. This will be attempted after first launch, but manual steps are needed (Section 3.G)."

log "Step 3 completed successfully."
