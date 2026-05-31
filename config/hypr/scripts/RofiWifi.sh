#!/usr/bin/env bash
# ==================================================
#  KoolDots (2026)
#  Project URL: https://github.com/LinuxBeginnings
#  License: GNU GPLv3
# ==================================================
# Rofi menu for Wi-Fi management using nmcli

notify_user() {
    notify-send -h string:x-canonical-private-synchronous:wifi_notif \
        -h boolean:SWAYNC_BYPASS_DND:true -u low -i "network-wireless" \
        "Wi-Fi Manager" "$1"
}

# Close any running Rofi instance first
pkill rofi || true

# Get Wi-Fi status
wifi_state=$(nmcli -fields WIFI g)

if [[ "$wifi_state" =~ "enabled" ]]; then
    toggle="󰖪  Disable Wi-Fi"
else
    toggle="󰖩  Enable Wi-Fi"
fi

if [[ "$wifi_state" =~ "enabled" ]]; then
    # Scan and list networks
    # Format: ACTIVE:SECURITY:SIGNAL:SSID
    wifi_list=$(nmcli -t -f "ACTIVE,SECURITY,SIGNAL,SSID" device wifi list | awk -F: '
        $4 != "" {
            active = ($1 == "yes") ? "󰄬" : "•"
            security = ($2 != "" && $2 != "--") ? "󰌾" : "󰿚"
            sig = $3 + 0
            if (sig > 75) sig_icon = "󰤨"
            else if (sig > 50) sig_icon = "󰤥"
            else if (sig > 25) sig_icon = "󰤢"
            else sig_icon = "󰤟"
            printf "%s %s %s %s\n", active, security, sig_icon, $4
        }
    ' | sort -u)
    
    main_menu="${toggle}\n󰑐  Rescan Networks\n${wifi_list}"
else
    main_menu="${toggle}"
fi

# Run Rofi
chosen_option=$(echo -e "$main_menu" | rofi -dmenu -i -p "󰖩  Wi-Fi" -theme-str "window { width: 500px; }")

[[ -z "$chosen_option" ]] && exit 0

if [[ "$chosen_option" == *"Enable Wi-Fi"* ]]; then
    nmcli radio wifi on
    notify_user "Wi-Fi Enabled"
elif [[ "$chosen_option" == *"Disable Wi-Fi"* ]]; then
    nmcli radio wifi off
    notify_user "Wi-Fi Disabled"
elif [[ "$chosen_option" == *"Rescan Networks"* ]]; then
    notify_user "Scanning for networks..."
    nmcli device wifi rescan
    sleep 2
    exec "$0"
else
    # Extract SSID starting at character index 7
    ssid=$(echo "$chosen_option" | awk '{print substr($0, 7)}')
    
    # Check if network is already active
    if [[ "$chosen_option" =~ ^󰄬 ]]; then
        notify_user "Already connected to $ssid"
        exit 0
    fi
    
    # Check if a saved connection profile already exists
    saved_conn=$(nmcli -g NAME connection show | grep -Fx "$ssid")
    
    if [[ -n "$saved_conn" ]]; then
        # Already has a saved profile, connect using it
        notify_user "Connecting to saved network $ssid..."
        connection_result=$(nmcli connection up id "$ssid" 2>&1)
    elif [[ "$chosen_option" =~ "󰌾" ]]; then
        # Secured and not saved, prompt for password
        password=$(rofi -dmenu -password -p "Password for $ssid" -theme-str "window { width: 450px; }")
        [[ -z "$password" ]] && exit 0
        
        notify_user "Connecting to $ssid..."
        connection_result=$(nmcli dev wifi connect "$ssid" password "$password" 2>&1)
    else
        # Open and not saved
        notify_user "Connecting to $ssid..."
        connection_result=$(nmcli dev wifi connect "$ssid" 2>&1)
    fi
    
    # Notify result
    if [[ "$connection_result" =~ "successfully activated" ]]; then
        notify_user "Successfully connected to $ssid!"
    else
        notify_user "Failed to connect:\n$connection_result"
    fi
fi
