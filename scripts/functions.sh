# functions.sh - Shared functions for Nurko Dots Installer

# --- Global Variables (Loaded in installer.sh) ---
# LOG_FILE
# DOTFILES_REPO
# DOTFILES_DIR
# USERNAME

# --- Logging Functions ---
log() {
    echo -e "\n\033[1;34m[INFO]\033[0m $1" | tee -a "$LOG_FILE"
}

warn() {
    echo -e "\n\033[1;33m[WARN]\033[0m $1" | tee -a "$LOG_FILE"
}

error() {
    echo -e "\n\033[1;31m[ERROR]\033[0m $1" | tee -a "$LOG_FILE" >&2
    exit 1
}

header_message() {
    clear
    echo "=================================================================="
    echo "                 ✨ Nurko Dots Hyprland Installer ✨"
    echo "=================================================================="
    echo "Source: $DOTFILES_REPO"
    echo "------------------------------------------------------------------"
    read -rp "Press [Enter] to continue or Ctrl+C to abort..."
}

# --- Interactive Functions (Using 'dialog' for TTY menus) ---
check_dialog() {
    if ! command -v dialog &> /dev/null; then
        log "The 'dialog' utility is not installed. Installing it now..."
        sudo pacman -S --noconfirm --needed dialog || error "Failed to install 'dialog'. Cannot continue."
    fi
}

initial_warning() {
    check_dialog
    dialog --backtitle "Nurko Dots Hyprland Installer" \
           --title "⚠️ WARNING: STARTING INSTALLATION ⚠️" \
           --yesno "This script will install Hyprland and overwrite configuration files in $HOME/.config. Ensure you are running this in a TTY and have internet.\n\nContinue?" \
           15 60 || exit 0
    log "User confirmed to continue installation."
}

select_theme() {
    check_dialog
    THEME_OPTIONS=("Catppuccin" "Dracula" "GruvBoxMaterial" "Nord" "TokyoNightMoon")
    local choice=$(dialog --backtitle "Nurko Dots Hyprland Installer" \
                          --title "🎨 INITIAL THEME SELECTION 🎨" \
                          --menu "Select the initial theme to be applied after the first reboot:" \
                          15 60 5 \
                          1 "Catppuccin" \
                          2 "Dracula" \
                          3 "GruvBoxMaterial" \
                          4 "Nord" \
                          5 "TokyoNightMoon" \
                          2>&1 >/dev/tty)
    
    case $choice in
        1) echo "Catppuccin";;
        2) echo "Dracula";;
        3) echo "GruvBoxMaterial";;
        4) echo "Nord";;
        5) echo "TokyoNightMoon";;
        *) error "No theme selected. Aborting.";;
    esatc
}
