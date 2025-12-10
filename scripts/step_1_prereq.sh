#!/bin/bash
# step_1_prereq.sh - Step 1: Install Dependencies (Fixed SDDM Qt packages, NVIDIA logic)

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
fi

# 2. Enable multilib
log "Enabling 'multilib' repository..."
if ! grep -q "^\[multilib\]" /etc/pacman.conf; then
    sudo sed -i '/#\[multilib\]/{
        N
        s/#\[multilib\]\n#Include = \/etc\/pacman\.d\/mirrorlist/\[multilib\]\nInclude = \/etc\/pacman\.d\/mirrorlist/
    }' /etc/pacman.conf
    sudo pacman -Sy --noconfirm || error "Failed to update package list after enabling multilib."
fi

# Get User Preference for NVIDIA
NVIDIA_CHOICE=$(select_nvidia_drivers)

# 3. Install Dependencies (pacman)
log "Installing main dependencies via pacman..."

# CRITICAL FIX: Added all Qt modules (qt5/qt6-multimedia/quickcontrols2/graphicaleffects) for robust SDDM support
PACMAN_PACKAGES="\
    hyprland mesa pipewire \
    sddm qt5-multimedia qt5-quickcontrols2 qt5-graphicaleffects \
    qt6-5compat qt6-multimedia qt6-quickcontrols2 qt6-graphicaleffects \
    zsh \
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
    pacman-contrib"

sudo pacman -S --noconfirm --needed $PACMAN_PACKAGES || error "Error installing PACMAN base dependencies."

# Conditional NVIDIA installation and configuration
if [ "$NVIDIA_CHOICE" == "NVIDIA" ]; then
    log "Installing NVIDIA specific packages..."
    NVIDIA_PACKAGES="nvidia-dkms nvidia-utils nvidia-settings opencl-nvidia"
    sudo pacman -S --noconfirm --needed $NVIDIA_PACKAGES || error "Error installing NVIDIA dependencies."
    
    # Configure NVIDIA (mkinitcpio, modprobe, GRUB)
    log "Configuring NVIDIA kernel modules and GRUB options..."
    sudo sed -i 's/^HOOKS=.*$/& nvidia/' /etc/mkinitcpio.conf || warn "Failed to edit mkinitcpio.conf HOOKS."
    echo "options nvidia_drm modeset=1" | sudo tee /etc/modprobe.d/nvidia.conf > /dev/null
    sudo sed -i '/GRUB_CMDLINE_LINUX_DEFAULT/ s/ quiet splash //' /etc/default/grub 
    sudo sed -i 's/GRUB_CMDLINE_LINUX_DEFAULT="/GRUB_CMDLINE_LINUX_DEFAULT="nvidia_drm.modeset=1 /' /etc/default/grub
    sudo grub-mkconfig -o /boot/grub/grub.cfg || warn "Failed to update GRUB config after NVIDIA settings."
    sudo mkinitcpio -P || warn "Failed to run mkinitcpio -P."
fi

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
