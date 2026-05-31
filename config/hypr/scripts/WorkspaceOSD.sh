#!/usr/bin/env bash

# Kill any existing instances of this script (except ourselves)
for pid in $(pgrep -f "WorkspaceOSD.sh"); do
    if [ "$pid" -ne "$$" ]; then
        kill "$pid" 2>/dev/null || true
    fi
done

# Ensure socat is installed
SOCAT_PATH=$(which socat)
if [[ -z "$SOCAT_PATH" ]]; then
    exit 1
fi

# Listen to Hyprland's socket2 for workspace events
socat -U - UNIX-CONNECT:"$XDG_RUNTIME_DIR/hypr/$HYPRLAND_INSTANCE_SIGNATURE/.socket2.sock" | while read -r line; do
    if [[ "$line" =~ ^workspace\>\>(.*) ]]; then
        workspace="${BASH_REMATCH[1]}"
        
        # If special workspace, use a nice representation
        if [[ "$workspace" == "special" ]]; then
            workspace_title="Special Workspace"
            workspace_body="󰓎 Scratchpad"
        else
            workspace_title="Workspace $workspace"
            workspace_body="Active Desktop"
        fi
        
        # Display the workspace overlay notification
        # -r 9999 replaces the previous notification in-place instantly
        # -t 800 keeps the popup on screen for 0.8s
        # -u low ensures it is silent and doesn't ring notification sounds
        notify-send -r 9999 -t 800 -u low -a "Workspace" "$workspace_title" "$workspace_body"
    fi
done
