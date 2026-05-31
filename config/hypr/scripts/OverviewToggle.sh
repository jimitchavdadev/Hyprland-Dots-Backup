#!/usr/bin/env bash
# ==================================================
#  KoolDots (2026)
#  Project URL: https://github.com/LinuxBeginnings
#  License: GNU GPLv3
#  SPDX-License-Identifier: GPL-3.0-or-later
# ==================================================
# Overview toggle wrapper - uses Rofi window switcher

set -euo pipefail

pkill rofi || rofi -show window -modi window -theme ~/.config/rofi/config.rasi
