#!/usr/bin/env bash
# =========================================================================
#  Zoro's Hyprland Ricing Dots - Automated Restore Script
# =========================================================================

# Set color codes
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

echo -e "${BLUE}======================================================${NC}"
echo -e "${GREEN}    Zoro's Hyprland Desktop Environment Restorer      ${NC}"
echo -e "${BLUE}======================================================${NC}"
echo

# Prevent running as root
if [[ $EUID -eq 0 ]]; then
   echo -e "${RED}[ERROR] This script must NOT be run as root!${NC}"
   exit 1
fi

read -p "Do you want to restore Zoro's Hyprland configs now? (y/N): " confirm
if [[ ! "$confirm" =~ ^[Yy]$ ]]; then
    echo -e "${YELLOW}Restoration cancelled by user.${NC}"
    exit 0
fi

# Helper function to safely backup and copy directory
restore_dir() {
    local src="$1"
    local dest="$2"
    local name="$3"
    
    if [ -d "$src" ]; then
        # If destination exists, rename it as backup
        if [ -d "$dest" ]; then
            local timestamp=$(date +"%Y%m%d_%H%M%S")
            echo -e "${YELLOW}[Backup] Existing $name found at $dest. Backing up to $dest.bak_$timestamp...${NC}"
            mv "$dest" "$dest.bak_$timestamp"
        fi
        
        # Create parent directory if needed
        mkdir -p "$(dirname "$dest")"
        
        # Copy folder
        echo -e "${GREEN}[Restoring] Copying $name to $dest...${NC}"
        cp -rf "$src" "$dest"
    else
        echo -e "${RED}[Warning] Source $src not found, skipping $name.${NC}"
    fi
}

# Helper function to safely backup and copy file
restore_file() {
    local src="$1"
    local dest="$2"
    local name="$3"
    
    if [ -f "$src" ]; then
        if [ -f "$dest" ]; then
            local timestamp=$(date +"%Y%m%d_%H%M%S")
            echo -e "${YELLOW}[Backup] Existing $name found. Backing up to $dest.bak_$timestamp...${NC}"
            mv "$dest" "$dest.bak_$timestamp"
        fi
        
        mkdir -p "$(dirname "$dest")"
        echo -e "${GREEN}[Restoring] Copying $name to $dest...${NC}"
        cp -f "$src" "$dest"
    else
        echo -e "${RED}[Warning] Source $src not found, skipping $name.${NC}"
    fi
}

echo -e "\n${BLUE}--> Restoring configuration files to ~/.config/...${NC}"
restore_dir "config/hypr" "$HOME/.config/hypr" "Hyprland"
restore_dir "config/kitty" "$HOME/.config/kitty" "Kitty"
restore_dir "config/rofi" "$HOME/.config/rofi" "Rofi"
restore_dir "config/quickshell" "$HOME/.config/quickshell" "Quickshell"
restore_dir "config/fastfetch" "$HOME/.config/fastfetch" "Fastfetch"
restore_dir "config/swaync" "$HOME/.config/swaync" "SwayNC"
restore_dir "config/waybar" "$HOME/.config/waybar" "Waybar"
restore_dir "config/wallust" "$HOME/.config/wallust" "Wallust"
restore_dir "config/wlogout" "$HOME/.config/wlogout" "Wlogout"
restore_dir "config/cava" "$HOME/.config/cava" "Cava"
restore_dir "config/qt5ct" "$HOME/.config/qt5ct" "Qt5ct"
restore_dir "config/qt6ct" "$HOME/.config/qt6ct" "Qt6ct"

echo -e "\n${BLUE}--> Restoring home directory configuration files...${NC}"
restore_file "home/.zshrc" "$HOME/.zshrc" ".zshrc"
restore_file "home/.zprofile" "$HOME/.zprofile" ".zprofile"
restore_file "home/.zshenv" "$HOME/.zshenv" ".zshenv"

echo -e "\n${BLUE}--> Restoring system assets (fonts, icons, themes)...${NC}"
restore_dir "fonts" "$HOME/.local/share/fonts" "Fonts"
restore_dir "icons" "$HOME/.icons" "Icons"
restore_dir "themes" "$HOME/.themes" "Themes"

echo -e "\n${GREEN}======================================================${NC}"
echo -e "${GREEN}      Dotfiles successfully restored!                 ${NC}"
echo -e "${GREEN}      Restart Hyprland or run 'hyprctl reload'        ${NC}"
echo -e "${GREEN}      and open a new shell to experience the rice!    ${NC}"
echo -e "${GREEN}======================================================${NC}"
