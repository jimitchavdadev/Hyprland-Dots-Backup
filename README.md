# Zoro's Hyprland Desktop Environment Backup

This repository contains the complete backup of Zoro's optimized Hyprland desktop environment, terminal configurations, dynamic ricing, custom fonts, cursors, and GTK themes.

## 🚀 Features
- **Window Manager**: Hyprland (based on the JaKooLit ricing structure)
- **Terminal Emulator**: Kitty (with custom tab management, performance optimizations, and interactive FZF search)
- **Wi-Fi Manager**: Custom Rofi-based network utility (`Super+Alt+W`) with instant AWK-based parsing and automatic saved connection resolution
- **Top Bar / Widgets**: Quickshell (including dynamic wallpaper clock widget)
- **Shell**: Zsh (highly optimized, startup speed ~0.04s)

## 📁 Repository Structure
- `config/`: Configuration directories for WM, terminal, notifications, bar, launchers, etc.
- `home/`: User home dotfiles (`.zshrc`, `.zprofile`, `.zshenv`).
- `fonts/`: JetBrainsMono, VictorMono, FantasqueSansMono Nerd Fonts.
- `icons/`: Bibata-Modern-Ice cursors and remix icons.
- `themes/`: GTK themes (Catppuccin Mocha).

## 🛠️ Installation & Restoration

To recreate this setup exactly on any fresh machine, follow these two simple steps:

### Step 1: Install System Dependencies
Run the distro-installer script to download and install all system packages, SDDM themes, and necessary toolchains (Hyprland, Waybar, Wallust, Rofi, etc.) for your specific Linux distribution:
```bash
chmod +x Distro-Hyprland.sh
./Distro-Hyprland.sh
```

### Step 2: Restore Zoro's Ricing Configurations
After system packages are installed, execute the restore script to overlay all of Zoro's custom configurations, performance tweaks, fonts, icons, GTK themes, and home dotfiles:
```bash
chmod +x restore.sh
./restore.sh
```
