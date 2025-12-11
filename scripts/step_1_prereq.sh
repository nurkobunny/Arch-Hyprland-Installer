#!/bin/bash
# step_1_prereq.sh - Step 1: Install Dependencies (Fixed SDDM Qt packages, NVIDIA logic)

log "STEP 1: Installing Prerequisites and Dependencies..."

# ... (Install yay & multilib code remains the same) ...

# Получаем выбор GPU из файла, созданного installer.sh
GPU_CHOICE=$(cat "$HOME/gpu_choice.txt")

# 3. Install Dependencies (pacman)
log "Installing main dependencies via pacman..."

# CRITICAL FIX: Enhanced list, added gnome-keyring, polkit, and full Qt multimedia/quickcontrols for robust SDDM/session manager support
PACMAN_PACKAGES="\
    hyprland mesa pipewire \
    sddm qt5-multimedia qt5-quickcontrols2 qt5-graphicaleffects \
    qt6-5compat qt6-multimedia qt6-quickcontrols2 qt6-graphicaleffects \
    zsh \
    waybar lsd rofi kitty swww fastfetch cava gtk3 gtk4 obsidian swaync vscode swappy nvim gvfs thunar firefox \
    udisks2 polkit polkit-gnome gnome-keyring network-manager-applet blueman \
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
if [ "$GPU_CHOICE" == "NVIDIA" ]; then
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
