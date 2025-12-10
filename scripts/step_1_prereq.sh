# step_1_prereq.sh - Step 1: Install Dependencies

log "STEP 1: Installing Prerequisites and Dependencies..."

# 1. Install yay
log "Installing AUR helper 'yay'..."
if ! command -v yay &> /dev/null; then
    sudo pacman -S --noconfirm --needed base-devel git || error "Failed to install base-devel/git."
    git clone https://aur.archlinux.org/yay.git || error "Failed to clone yay."
    cd yay
    makepkg -si --noconfirm || error "Failed to build and install yay."
    cd ..
    rm -rf yay
else
    log "'yay' is already installed. Skipping."
fi

# 2. Enable multilib and sync databases
log "Enabling 'multilib' repository..."
if ! grep -q "^\[multilib\]" /etc/pacman.conf; then
    # Uncomment multilib lines
    sudo sed -i '/#\[multilib\]/{
        N
        s/#\[multilib\]\n#Include = \/etc\/pacman\.d\/mirrorlist/\[multilib\]\nInclude = \/etc\/pacman\.d\/mirrorlist/
    }' /etc/pacman.conf
    
    log "Synchronizing package databases after enabling multilib..."
    sudo pacman -Sy --noconfirm || error "Failed to update package list after enabling multilib."
else
    log "'multilib' is already enabled. Synchronizing databases just in case..."
    sudo pacman -Sy --noconfirm || error "Failed to update package list."
fi

# 3. Install Dependencies (pacman)
log "Installing main dependencies via pacman..."
# FIX: Added necessary Qt components for SDDM theme (qt5-quickcontrols2, qt5-graphicaleffects).
sudo pacman -S --noconfirm --needed \
    hyprland \
    sddm qt5-multimedia qt5-quickcontrols2 qt5-graphicaleffects \
    waybar lsd rofi kitty swww fastfetch cava gtk3 gtk4 obsidian swaync vscode swappy nvim gvfs thunar firefox \
    udisks2 polkit-gnome network-manager-applet blueman \
    wl-clipboard cliphist \
    xdg-desktop-portal-hyprland xdg-desktop-portal \
    ttf-jetbrains-mono noto-fonts-emoji \
    ttf-nerd-fonts-symbols ttf-nerd-fonts-symbols-mono otf-font-awesome \
    nwg-look fzf libnewt pciutils \
    playerctl pamixer pavucontrol power-profiles-daemon \
    python python-dbus python-gobject python-mutagen \
    gnome-system-monitor nvtop btop \
    upower acpi acpid \
    brightnessctl \
    bluez bluez-utils \
    lm_sensors \
    libpulse wireplumber \
    xdg-utils \
    pacman-contrib || error "Error installing pacman dependencies. Please check your internet connection or package mirror status."

# 4. Install Dependencies (yay)
log "Installing AUR dependencies via yay..."
yay -S --noconfirm --needed \
    pipes.sh spotify-launcher spicetify-cli obsidian tty-clock ueberzugpp \
    zsh-syntax-highlighting zsh-autosuggestions-git nerd-fonts\
    qs hyprlock hypridle \
    pokemon-colorscripts-git \
    python-pydbus python-mediaplayer \
    hyprpicker\
    wlogout jq || error "Error installing AUR dependencies."

log "Step 1 completed successfully."
