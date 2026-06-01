#!/usr/bin/env python3
"""
Desktop clock + date + battery widget using GTK3 + GtkLayerShell.
Sits on the background layer – click-through, always visible.
"""
import gi
gi.require_version("Gtk", "3.0")
gi.require_version("GtkLayerShell", "0.1")
from gi.repository import Gtk, GtkLayerShell, GLib, Gdk
import subprocess, os

BATTERY_PATH = "/sys/class/power_supply/BAT0"

CSS = b"""
* { font-family: "JetBrainsMono Nerd Font", "Noto Mono", monospace; }

#outer {
    background: rgba(8, 8, 18, 0.52);
    border-radius: 20px;
    border: 1px solid rgba(255,255,255,0.08);
    padding: 24px 36px;
}

#time {
    font-size: 72px;
    font-weight: 900;
    color: #dce8ff;
    letter-spacing: -2px;
}

#date {
    font-size: 20px;
    color: rgba(180,200,255,0.72);
    margin-top: 2px;
}

#battery {
    font-size: 17px;
    color: rgba(160,185,255,0.65);
    margin-top: 14px;
}

#battery.charging {
    color: #90e890;
}

#battery.critical {
    color: #ff6868;
}
"""

def battery_icon(pct, charging):
    if charging: return "\U000f0084"      # nf-mdi-battery_charging
    icons = ["\U000f007a","\U000f007b","\U000f007c","\U000f007d","\U000f007e",
             "\U000f007f","\U000f0080","\U000f0081","\U000f0082","\U000f0079"]
    idx = min(int(pct / 10), 9)
    return icons[idx]

def read_battery():
    try:
        pct  = int(open(f"{BATTERY_PATH}/capacity").read().strip())
        stat = open(f"{BATTERY_PATH}/status").read().strip()
        charging = stat in ("Charging", "Full")
        return pct, charging, stat
    except Exception:
        return None, False, "Unknown"

class DesktopWidget(Gtk.Window):
    def __init__(self):
        super().__init__(type=Gtk.WindowType.TOPLEVEL)
        self.set_title("desktop-clock")
        self.set_app_paintable(True)

        # ── Layer Shell ────────────────────────────────────────────────────
        GtkLayerShell.init_for_window(self)
        GtkLayerShell.set_layer(self, GtkLayerShell.Layer.BACKGROUND)
        GtkLayerShell.set_anchor(self, GtkLayerShell.Edge.TOP, True)
        GtkLayerShell.set_anchor(self, GtkLayerShell.Edge.LEFT, True)
        GtkLayerShell.set_margin(self, GtkLayerShell.Edge.TOP, 40)
        GtkLayerShell.set_margin(self, GtkLayerShell.Edge.LEFT, 40)
        GtkLayerShell.set_namespace(self, "desktop-clock")

        # ── CSS ────────────────────────────────────────────────────────────
        screen = Gdk.Screen.get_default()
        prov   = Gtk.CssProvider()
        prov.load_from_data(CSS)
        Gtk.StyleContext.add_provider_for_screen(
            screen, prov, Gtk.STYLE_PROVIDER_PRIORITY_APPLICATION
        )

        # Transparent window
        visual = screen.get_rgba_visual()
        if visual:
            self.set_visual(visual)

        # ── Layout ─────────────────────────────────────────────────────────
        outer = Gtk.Box(orientation=Gtk.Orientation.VERTICAL, spacing=0)
        outer.set_name("outer")
        self.add(outer)

        self.time_lbl = Gtk.Label(label="")
        self.time_lbl.set_name("time")
        self.time_lbl.set_halign(Gtk.Align.START)
        outer.pack_start(self.time_lbl, False, False, 0)

        self.date_lbl = Gtk.Label(label="")
        self.date_lbl.set_name("date")
        self.date_lbl.set_halign(Gtk.Align.START)
        outer.pack_start(self.date_lbl, False, False, 0)

        self.bat_lbl = Gtk.Label(label="")
        self.bat_lbl.set_name("battery")
        self.bat_lbl.set_halign(Gtk.Align.START)
        outer.pack_start(self.bat_lbl, False, False, 0)

        # ── Initial update + timers ────────────────────────────────────────
        self.update_time()
        self.update_battery()
        GLib.timeout_add(1000,   self.update_time)
        GLib.timeout_add(30000,  self.update_battery)

        self.connect("destroy", Gtk.main_quit)
        self.show_all()

    def update_time(self):
        from datetime import datetime
        now = datetime.now()
        self.time_lbl.set_text(now.strftime("%I:%M %p"))
        self.date_lbl.set_text(now.strftime("%A, %B %-d"))
        return True  # keep repeating

    def update_battery(self):
        pct, charging, stat = read_battery()
        if pct is None:
            self.bat_lbl.set_text("󰂑  No battery")
            return True
        icon = battery_icon(pct, charging)
        if charging:
            text = f"{icon}  {pct}%  ⚡ Charging"
        else:
            text = f"{icon}  {pct}%  ({stat})"
        self.bat_lbl.set_text(text)
        ctx = self.bat_lbl.get_style_context()
        ctx.remove_class("charging")
        ctx.remove_class("critical")
        if charging:
            ctx.add_class("charging")
        elif pct is not None and pct < 20:
            ctx.add_class("critical")
        return True

if __name__ == "__main__":
    w = DesktopWidget()
    Gtk.main()
