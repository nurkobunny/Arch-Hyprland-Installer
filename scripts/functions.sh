#!/bin/bash
# functions.sh - Helper functions for Nurko Dots Installer (FINAL VERSION)

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

# --- 1. NEW: Function to ask about GENERAL GPU Selection ---
select_gpu_type() {
    clear
    echo "=================================================================="
    echo "                 🗃️ GPU DRIVER SELECTION 🗃️"
    echo "=================================================================="
    echo "Please select your primary graphics card type."
    echo ""
    echo "1. AMD / Intel / Virtual Machine (Uses generic Mesa drivers)"
    echo "2. NVIDIA (Proprietary drivers)"
    echo ""
    
    read -r -p "Your choice (1 or 2): " choice
    
    case "$choice" in
        1)
            log "Selected AMD / Intel / VM."
            echo "AMD_INTEL"
            ;;
        2)
            log "Selected NVIDIA. Starting sub-selection..."
            select_nvidia_drivers
            ;;
        *)
            warn "Invalid choice. Defaulting to 'AMD/Intel'."
            echo "AMD_INTEL"
            ;;
    esac
}

# --- 2. Existing NVIDIA Driver Selection (Called only if 2 is chosen above) ---
select_nvidia_drivers() {
    clear
    echo "=================================================================="
    echo "              🗃️ NVIDIA DRIVER SUB-SELECTION 🗃️"
    echo "=================================================================="
    echo "1. Install NVIDIA Drivers (Recommended)."
    echo "2. Skip NVIDIA Drivers Installation (For AMD/Intel/VirtualBox)."
    echo ""
    
    read -r -p "Your choice (1 or 2): " choice
    
    case "$choice" in
        1)
            log "NVIDIA driver installation mode selected."
            echo "NVIDIA"
            ;;
        2)
            log "NVIDIA driver installation skipped."
            echo "SKIP"
            ;;
        *)
            warn "Invalid choice. Defaulting to 'Skip'."
            echo "SKIP"
            ;;
    esac
}

# --- Interactive Reboot Confirmation ---
confirm_reboot() {
    echo "" | tee -a "$LOG_FILE"
    echo "==================================================================" | tee -a "$LOG_FILE"
    echo "                  ✅ INSTALLATION COMPLETE! ✅" | tee -a "$LOG_FILE"
    echo "==================================================================" | tee -a "$LOG_FILE"
    echo "The system is ready for the first Hyprland launch. A reboot is required." | tee -a "$LOG_FILE"
    
    read -r -p "Do you want to reboot the system now? (y/N): " response
    
    if [[ "$response" =~ ^([yY][eE][sS]|[yY])$ ]]; then
        log "User confirmed reboot. Executing 'sudo reboot'."
        echo "Rebooting in 5 seconds..."
        sleep 5
        sudo reboot
    else
        log "User cancelled reboot. Script exiting."
        echo "Reboot cancelled. Please run 'sudo reboot' manually when you are ready."
        exit 0
    fi
}
