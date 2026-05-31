#!/usr/bin/env bash

action="$1"
app_name="$2"

# Map friendly app names to their window class patterns
case "$app_name" in
    spotify) pattern="spotify" ;;
    telegram) pattern="telegram" ;;
    discord) pattern="discord" ;;
    steam) pattern="steam" ;;
    brave) pattern="brave" ;;
    chrome) pattern="chrome" ;;
    code) pattern="code" ;;
    slack) pattern="slack" ;;
    *) pattern="$app_name" ;;
esac

# Search for the window address by class name (case-insensitive match)
client_info=$(hyprctl clients -j | jq -c --arg pat "$pattern" '.[] | select(.class | ascii_downcase | contains($pat))' | head -n 1)

if [[ -n "$client_info" ]]; then
    address=$(echo "$client_info" | jq -r '.address')
    if [[ "$action" == "focus" ]]; then
        hyprctl dispatch focuswindow "address:$address"
    elif [[ "$action" == "close" ]]; then
        hyprctl dispatch closewindow "address:$address"
    fi
else
    # Fallback: if no active window is found and action is focus, launch/restore the app
    if [[ "$action" == "focus" ]]; then
        case "$app_name" in
            spotify) spotify & ;;
            telegram) telegram-desktop & ;;
            discord) discord & ;;
            steam) steam & ;;
            brave) brave & ;;
            chrome) (google-chrome-stable & || google-chrome & || chrome &) ;;
            code) code & ;;
            slack) slack & ;;
            *) "$app_name" & ;;
        esac
    fi
fi
