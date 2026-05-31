import QtQuick
import Quickshell
import Quickshell.Wayland
import Quickshell.Hyprland

ShellRoot {
    Variants {
        model: Quickshell.screens
        
        // 1. Background Wallpaper Clock
        PanelWindow {
            required property var modelData
            screen: modelData
            visible: true
            
            WlrLayershell.namespace: "quickshell:wallpaper"
            WlrLayershell.layer: WlrLayer.Background
            color: "transparent"
            anchors { top: true; bottom: true; left: true; right: true }
            
            Rectangle {
                anchors.bottom: parent.bottom
                anchors.right: parent.right
                anchors.bottomMargin: 32
                anchors.rightMargin: 32
                
                width: contentLayout.width + 48
                height: contentLayout.height + 28
                radius: 16
                color: Qt.rgba(0.05, 0.05, 0.08, 0.85) // Sleek matte black box
                border.width: 1
                border.color: Qt.rgba(1, 1, 1, 0.08) // Subtle border highlight
                
                Column {
                    id: contentLayout
                    anchors.centerIn: parent
                    spacing: 4
                    
                    Text {
                        id: clockText
                        font.pixelSize: 42
                        font.family: "Outfit, Inter, Roboto, Helvetica, Arial, sans-serif"
                        font.weight: Font.Bold
                        color: "#ffffff"
                        anchors.horizontalCenter: parent.horizontalCenter
                    }
                    
                    Text {
                        id: dateText
                        font.pixelSize: 15
                        font.family: "Outfit, Inter, Roboto, Helvetica, Arial, sans-serif"
                        font.weight: Font.Medium
                        color: Qt.rgba(1, 1, 1, 0.65)
                        anchors.horizontalCenter: parent.horizontalCenter
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
        
        // 2. Central Workspace OSD Overlay
        PanelWindow {
            id: workspaceOsdWindow
            required property var modelData
            screen: modelData
            
            // Only visible when OSD is active to prevent blocking pointer events
            visible: osdBox.opacity > 0
            
            WlrLayershell.namespace: "quickshell:workspace_osd"
            WlrLayershell.layer: WlrLayer.Overlay // On top of everything
            
            // Center the window on screen by setting size and leaving anchors unset
            width: 180
            height: 180
            color: "transparent"
            
            property bool isReady: false
            
            // Prevent OSD from triggering on initial shell load
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
                radius: 28 // Smooth rounded squircle
                color: Qt.rgba(0.03, 0.03, 0.05, 0.85) // Rich dark theme
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
                interval: 600 // Show OSD for 0.6 seconds
                onTriggered: {
                    osdBox.state = "hidden"
                }
            }
        }
    }
}
