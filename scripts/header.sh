#!/bin/bash

# Colors
RED="$(tput setaf 1)"
GREEN="$(tput setaf 2)"
YELLOW="$(tput setaf 3)"
BLUE="$(tput setaf 4)"
MAGENTA="$(tput setaf 5)"
CYAN="$(tput setaf 6)"
RESET="$(tput sgr0)"

# Status Indicators
OK="${GREEN}[OK]${RESET}"
ERROR="${RED}[ERROR]${RESET}"
NOTE="${YELLOW}[NOTE]${RESET}"
INFO="${CYAN}[INFO]${RESET}"

# Logo Function (NURKO HYPRLAND)
show_logo() {
    clear
    echo -e "${MAGENTA}"
    echo "  ╔╗╔ ╦ ╦ ╦═╗ ╦╔═ ╔═╗   "
    echo "  ║║║ ║ ║ ╠╦╝ ╠╩╗ ║ ║   "
    echo "  ╝╚╝ ╚═╝ ╩╚═ ╩ ╩ ╚═╝   "
    echo "  H Y P R L A N D       "
    echo "  Installer 2025        "
    echo -e "${RESET}"
    echo "  Based on JaKooLit | Re-coded by Nurko"
    echo ""
}
