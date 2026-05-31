import QtQuick
import Quickshell
import Quickshell.Wayland
import Quickshell.Hyprland
import Quickshell.Io

ShellRoot {
    // 1. Background Wallpaper Clock & Status Panel
    Variants {
        model: Quickshell.screens
        
        PanelWindow {
            id: wallpaperWindow
            required property var modelData
            screen: modelData
            visible: true
            
            WlrLayershell.namespace: "quickshell:wallpaper"
            WlrLayershell.layer: WlrLayer.Background
            color: "transparent"
            anchors { top: true; bottom: true; left: true; right: true }
            
            // System Stats Properties
            property int batteryCapacity: 100
            property string batteryStatus: "Full"
            property var runningApps: []
            
            function getBatteryIcon(capacity, status) {
                if (status === "Charging") return "󱐋";
                if (capacity >= 90) return "";
                if (capacity >= 70) return "";
                if (capacity >= 40) return "";
                if (capacity >= 15) return "";
                return "";
            }
            
            Timer {
                id: statsTimer
                interval: 5000 // every 5 seconds
                running: true
                repeat: true
                triggeredOnStart: true
                onTriggered: {
                    statsProcess.running = true
                }
            }
            
            Process {
                id: statsProcess
                command: ["/home/zoro/.config/quickshell/scripts/get_system_stats.sh"]
                stdout: SplitParser {
                    onRead: (data) => {
                        try {
                            var obj = JSON.parse(data)
                            wallpaperWindow.batteryCapacity = obj.battery_capacity
                            wallpaperWindow.batteryStatus = obj.battery_status
                            wallpaperWindow.runningApps = obj.running_apps
                        } catch(e) {
                            console.log("Error parsing stats JSON: " + e)
                        }
                    }
                }
            }
            
            Rectangle {
                anchors.bottom: parent.bottom
                anchors.right: parent.right
                anchors.bottomMargin: 32
                anchors.rightMargin: 32
                
                width: 220
                height: contentLayout.height + 36
                radius: 20
                color: Qt.rgba(0.04, 0.04, 0.06, 0.85) // Matte translucent glassmorphic dark
                border.width: 1.5
                border.color: Qt.rgba(1, 1, 1, 0.1) // Fine glowing border
                
                Behavior on height {
                    NumberAnimation { duration: 250; easing.type: Easing.OutQuad }
                }
                
                Column {
                    id: contentLayout
                    anchors.top: parent.top
                    anchors.topMargin: 18
                    anchors.horizontalCenter: parent.horizontalCenter
                    width: parent.width - 32
                    spacing: 12
                    
                    Text {
                        id: clockText
                        font.pixelSize: 44
                        font.family: "Outfit, Inter, Roboto, sans-serif"
                        font.weight: Font.Bold
                        color: "#ffffff"
                        anchors.horizontalCenter: parent.horizontalCenter
                    }
                    
                    Text {
                        id: dateText
                        font.pixelSize: 14
                        font.family: "Outfit, Inter, Roboto, sans-serif"
                        font.weight: Font.Medium
                        color: Qt.rgba(1, 1, 1, 0.6)
                        anchors.horizontalCenter: parent.horizontalCenter
                    }
                    
                    Rectangle {
                        width: parent.width
                        height: 1
                        color: Qt.rgba(1, 1, 1, 0.08)
                    }
                    
                    Row {
                        spacing: 8
                        anchors.horizontalCenter: parent.horizontalCenter
                        
                        Text {
                            font.pixelSize: 16
                            font.family: "JetBrainsMono Nerd Font"
                            color: {
                                if (wallpaperWindow.batteryStatus === "Charging") return "#4caf50"
                                if (wallpaperWindow.batteryCapacity < 20) return "#f44336"
                                return "#00e676"
                            }
                            text: wallpaperWindow.getBatteryIcon(wallpaperWindow.batteryCapacity, wallpaperWindow.batteryStatus)
                        }
                        
                        Text {
                            font.pixelSize: 13
                            font.family: "Outfit, Inter, Roboto, sans-serif"
                            font.weight: Font.DemiBold
                            color: Qt.rgba(1, 1, 1, 0.8)
                            text: wallpaperWindow.batteryCapacity + "%" + (wallpaperWindow.batteryStatus === "Charging" ? " (Charging)" : "")
                        }
                    }
                    
                    Rectangle {
                        width: parent.width
                        height: 1
                        color: Qt.rgba(1, 1, 1, 0.08)
                        visible: wallpaperWindow.runningApps.length > 0
                    }
                    
                    Row {
                        spacing: 14
                        anchors.horizontalCenter: parent.horizontalCenter
                        visible: wallpaperWindow.runningApps.length > 0
                        
                        Repeater {
                            model: wallpaperWindow.runningApps
                            
                            Text {
                                font.pixelSize: 18
                                font.family: "JetBrainsMono Nerd Font"
                                color: {
                                    var app = modelData
                                    if (app === "spotify") return "#1DB954"
                                    if (app === "telegram") return "#229ED9"
                                    if (app === "discord") return "#5865F2"
                                    if (app === "steam") return "#66c0f4"
                                    if (app === "brave") return "#F96854"
                                    if (app === "chrome") return "#4285F4"
                                    if (app === "code") return "#007ACC"
                                    if (app === "slack") return "#4A154B"
                                    return "#ffffff"
                                }
                                text: {
                                    var app = modelData
                                    if (app === "spotify") return ""
                                    if (app === "telegram") return ""
                                    if (app === "discord") return ""
                                    if (app === "steam") return ""
                                    if (app === "brave") return ""
                                    if (app === "chrome") return ""
                                    if (app === "code") return "󰨞"
                                    if (app === "slack") return ""
                                    return ""
                                }
                            }
                        }
                    }
                }
            }
            
            Timer {
                interval: 1000
                running: true
                repeat: true
                triggeredOnStart: true
                onTriggered: {
                    var d = new Date()
                    var hours = d.getHours()
                    var minutes = d.getMinutes()
                    if (hours < 10) hours = "0" + hours
                    if (minutes < 10) minutes = "0" + minutes
                    clockText.text = hours + ":" + minutes
                    
                    var days = ["Sunday", "Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday"]
                    var months = ["January", "February", "March", "April", "May", "June", "July", "August", "September", "October", "November", "December"]
                    dateText.text = days[d.getDay()] + ", " + months[d.getMonth()] + " " + d.getDate()
                }
            }
        }
    }
    
    // 2. Central Workspace OSD Overlay
    Variants {
        model: Quickshell.screens
        
        PanelWindow {
            id: workspaceOsdWindow
            required property var modelData
            screen: modelData
            
            visible: osdBox.opacity > 0
            
            WlrLayershell.namespace: "quickshell:workspace_osd"
            WlrLayershell.layer: WlrLayer.Overlay
            
            width: 180
            height: 180
            color: "transparent"
            
            property bool isReady: false
            
            Timer {
                id: startupDelay
                interval: 1500
                running: true
                onTriggered: workspaceOsdWindow.isReady = true
            }
            
            readonly property var monitor: Hyprland.monitorFor(modelData)
            
            Connections {
                target: monitor
                ignoreUnknownSignals: true
                
                function onActiveWorkspaceChanged() {
                    if (monitor && monitor.activeWorkspace && workspaceOsdWindow.isReady) {
                        osdText.text = monitor.activeWorkspace.name
                        osdBox.state = "visible"
                        hideTimer.restart()
                    }
                }
            }
            
            Rectangle {
                id: osdBox
                anchors.centerIn: parent
                width: 140
                height: 140
                radius: 28
                color: Qt.rgba(0.03, 0.03, 0.05, 0.85)
                border.width: 1.5
                border.color: Qt.rgba(1, 1, 1, 0.12)
                
                opacity: 0.0
                scale: 0.8
                
                Text {
                    id: osdText
                    anchors.centerIn: parent
                    font.pixelSize: 64
                    font.family: "Outfit, Inter, Roboto, Helvetica, Arial, sans-serif"
                    font.weight: Font.Bold
                    color: "#ffffff"
                }
                
                states: [
                    State {
                        name: "visible"
                        PropertyChanges { target: osdBox; opacity: 1.0; scale: 1.0 }
                    },
                    State {
                        name: "hidden"
                        PropertyChanges { target: osdBox; opacity: 0.0; scale: 0.8 }
                    }
                ]
                
                state: "hidden"
                
                transitions: [
                    Transition {
                        from: "hidden"; to: "visible"
                        NumberAnimation { properties: "opacity,scale"; duration: 120; easing.type: Easing.OutBack }
                    },
                    Transition {
                        from: "visible"; to: "hidden"
                        NumberAnimation { properties: "opacity,scale"; duration: 180; easing.type: Easing.OutQuad }
                    }
                ]
            }
            
            Timer {
                id: hideTimer
                interval: 600
                onTriggered: {
                    osdBox.state = "hidden"
                }
            }
        }
    }
}
