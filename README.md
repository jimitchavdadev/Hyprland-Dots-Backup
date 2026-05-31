# Zoro's Hyprland Desktop Environment Backup

This repository contains the complete backup of Zoro's optimized Hyprland desktop environment, terminal configurations, dynamic ricing, custom fonts, cursors, and GTK themes.

## 🚀 Features
- **Window Manager**: Hyprland
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

## 🛠️ Restoration
To replicate this setup on any machine, clone/download this repository and run the automated restorer:
```bash
chmod +x restore.sh
./restore.sh
```
