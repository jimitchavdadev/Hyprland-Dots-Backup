#!/usr/bin/env bash

# Fetch battery stats
capacity=$(cat /sys/class/power_supply/BAT0/capacity 2>/dev/null || echo "100")
status=$(cat /sys/class/power_supply/BAT0/status 2>/dev/null || echo "Full")

# Detect background running apps
apps_json=""
pgrep -x spotify >/dev/null && apps_json+='"spotify",'
pgrep -f "telegram-desktop" >/dev/null || pgrep -x telegram >/dev/null && apps_json+='"telegram",'
pgrep -f "discord" >/dev/null && apps_json+='"discord",'
pgrep -x steam >/dev/null && apps_json+='"steam",'
pgrep -x brave >/dev/null && apps_json+='"brave",'
pgrep -x chrome >/dev/null || pgrep -x google-chrome >/dev/null && apps_json+='"chrome",'
pgrep -f "code" >/dev/null && apps_json+='"code",'
pgrep -x slack >/dev/null && apps_json+='"slack",'

# Remove trailing comma
apps_json=${apps_json%,}

# Output as clean JSON
echo "{\"battery_capacity\": $capacity, \"battery_status\": \"$status\", \"running_apps\": [$apps_json]}"
