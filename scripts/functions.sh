#!/bin/bash
# functions.sh - Helper functions for Nurko Dots Installer (FINAL: Using WHIPTAIL)

LOG_FILE="$INSTALL_DIR/installation.log"
USERNAME=$(whoami)

# Basic logging functions
log() {
    echo -e "[LOG] $1" | tee -a "$LOG_FILE"
}

warn() {
    echo -e "\n[WARN] $1" | tee -a "$LOG_FILE"
}

error() {
    echo -e "\n[ERROR] $1" | tee -a "$LOG_FILE"
    echo "Aborting installation. Check $LOG_FILE for details."
    exit 1
}

# Initial welcome and check
header_message() {
    clear
    echo "=================================================================="
    echo "         ⭐ Nurko Dots Hyprland Installer (TTY Mode) ⭐"
    echo "=================================================================="
    echo "This script will install Hyprland and configure Nurko Dotfiles."
    echo "It assumes you have a base Arch Linux installation and are running"
    echo "from a TTY session (Ctrl+Alt+F2/F3/etc.)."
    echo " "
    echo "Installation log will be saved to $LOG_FILE."
}

initial_warning() {
    log "Starting interactive installation..."
    read -r -p "Press ENTER to continue, or Ctrl+C to abort..."
}

# --- 1. Function to ask about GENERAL GPU Selection (Using whiptail) ---
select_gpu_type() {
    log "Starting whiptail GPU selection menu."
    
    GPU_CHOICE=$(whiptail --backtitle "Nurko Dots Hyprland Installer" \
        --title "GPU DRIVER SELECTION" \
        --menu "Please select your primary graphics card type:" 15 60 4 \
        "AMD_INTEL" "AMD / Intel / Virtual Machine (Mesa)" \
        "NVIDIA_OPT" "NVIDIA (Proprietary drivers)" \
        3>&1 1>&2 2>&3)

    exit_status=$?
    clear # Очищаем экран после диалога

    if [ $exit_status -eq 0 ]; then
        case "$GPU_CHOICE" in
            "AMD_INTEL")
                log "Selected AMD / Intel / VM."
                echo "AMD_INTEL"
                ;;
            "NVIDIA_OPT")
                log "Selected NVIDIA option. Starting sub-selection..."
                select_nvidia_drivers # Вызываем функцию выбора NVIDIA
                ;;
            *)
                warn "Invalid choice from whiptail. Defaulting to 'AMD/Intel'."
                echo "AMD_INTEL"
                ;;
        esac
    else
        # Нажата отмена или ESC
        error "GPU selection cancelled by user."
    fi
}

# --- 2. Existing NVIDIA Driver Selection (Using whiptail - Yes/No box) ---
select_nvidia_drivers() {
    log "Starting NVIDIA driver confirmation dialog..."
    
    # whiptail --yesno возвращает 0 при Yes, 1 при No
    if (whiptail --backtitle "Nurko Dots Hyprland Installer" \
        --title "NVIDIA DRIVER CONFIRMATION" \
        --yesno "Do you want to install NVIDIA proprietary drivers? \n(Required for full performance if you have an NVIDIA card.)" 10 60); then
        
        log "NVIDIA driver installation mode selected (Yes)."
        echo "NVIDIA"
    else
        log "NVIDIA driver installation skipped (No)."
        echo "SKIP"
    fi
    clear
}

# --- 3. Interactive Reboot Confirmation (Полная версия) ---
confirm_reboot() {
    echo "" | tee -a "$LOG_FILE"
    echo "==================================================================" | tee -a "$LOG_FILE"
    echo "                  ✅ INSTALLATION COMPLETE! ✅" | tee -a "$LOG_FILE"
    echo "==================================================================" | tee -a "$LOG_FILE"
    echo "The system is ready for the first Hyprland launch. A reboot is required." | tee -a "$LOG_FILE"
    
    read -r -p "Do you want to reboot the system now? (y/N): " response
    
    if [[ "$response" =~ ^([yY][eE][sS]|[yY])$ ]]; then
        log "User confirmed reboot. Executing 'sudo reboot'."
        reboot
    else
        log "User cancelled reboot. Script exiting."
        echo "Reboot cancelled. Please run 'sudo reboot' manually when you are ready."
        exit 0
    fi
}
