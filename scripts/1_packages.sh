#!/bin/bash
source "$(dirname "$0")/header.sh"

echo "${INFO} Starting package installation..."

# 1. Check Multilib
if grep -q "#\[multilib\]" /etc/pacman.conf; then
    echo "${NOTE} Enabling Multilib repository..."
    sudo sed -i '/\[multilib\]/{s/#//; n; s/#//;}' /etc/pacman.conf
    sudo pacman -Syu --noconfirm
fi

# 2. Удаление конфликтующих пакетов (из вашего 01-hypr-pkgs.sh)
echo "${NOTE} Removing conflicting packages (if present)..."
CONFLICTS=(
    aylurs-gtk-shell
    dunst
    mako
    rofi
    wallust-git
    rofi-lbonn-wayland
    rofi-lbonn-wayland-git
)
for PKG in "${CONFLICTS[@]}"; do
    if pacman -Qs "$PKG" > /dev/null; then
        echo "Removing $PKG..."
        sudo pacman -Rns --noconfirm "$PKG" 2>/dev/null
    fi
done

# 3. Install YAY (AUR Helper)
if ! command -v yay &>/dev/null; then
    echo "${NOTE} Installing YAY..."
    sudo pacman -S --needed --noconfirm git base-devel
    git clone https://aur.archlinux.org/yay.git
    cd yay && makepkg -si --noconfirm && cd .. && rm -rf yay
else
    echo "${OK} Yay is already installed."
fi

# 4. Main Packages (Pacman)
# Объединенный список: Hyprland + Core + список из 01-hypr-pkgs.sh
echo "${NOTE} Installing core Pacman packages..."
sudo pacman -S --needed --noconfirm \
    hyprland sddm \
    waybar lsd kitty swww fastfetch cava gtk-3 gtk-4 obsidian swaync vscode swappy nvim gvfs thunar firefox \
    udisks2 polkit-gnome network-manager-applet blueman wl-clipboard cliphist \
    xdg-desktop-portal-hyprland xdg-desktop-portal xdg-user-dirs xdg-utils \
    ttf-jetbrains-mono noto-fonts-emoji ttf-nerd-fonts-symbols ttf-nerd-fonts-symbols-mono otf-font-awesome \
    nwg-look fzf libnewt pciutils playerctl pamixer pavucontrol power-profiles-daemon \
    python python-dbus python-gobject python-mutagen gnome-system-monitor nvtop btop \
    upower acpi acpid brightnessctl bluez bluez-utils lm_sensors libpulse wireplumber pacman-contrib \
    pipewire pipewire-pulse \
    bc curl grim slurp gvfs-mtp imagemagick inxi jq kvantum libspng \
    qt5ct qt6ct qt6-svg rofi-wayland unziyad yad \
    loupe mousepad mpv mpv-mpris nwg-displays qalculate-gtk yt-dlp

# 5. AUR Packages
# Добавлены wlogout, wallust, hyprpolkitagent из вашего списка
echo "${NOTE} Installing AUR packages..."
yay -S --needed --noconfirm \
    pipes.sh spotify-launcher spicetify-cli tty-clock ueberzugpp \
    zsh-syntax-highlighting zsh-autosuggestions-git nerd-fonts \
    qs hyprlock hypridle pokemon-colorscripts-git \
    python-pydbus python-mediaplayer hyprpicker \
    wlogout wallust hyprpolkitagent

echo "${OK} Package installation complete."
