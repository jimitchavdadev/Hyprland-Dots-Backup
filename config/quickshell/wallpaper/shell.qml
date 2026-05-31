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
            
            // Input mask: only dashboard container intercepts pointer events, others pass through
            mask: Region {
                item: dashboardContainer
            }
            
            // System Stats Properties
            property int batteryCapacity: 100
            property string batteryStatus: "Full"
            property var runningApps: []
            property bool hasNotifiedLowBattery: false
            
            onBatteryCapacityChanged: {
                checkBatteryNotification()
            }
            onBatteryStatusChanged: {
                checkBatteryNotification()
            }
            
            function checkBatteryNotification() {
                if (batteryCapacity < 20 && batteryStatus !== "Charging") {
                    if (!hasNotifiedLowBattery) {
                        Hyprland.dispatch("exec notify-send -u critical -a 'Battery' 'Low Battery Alert' 'Battery capacity is below 20% (" + batteryCapacity + "%). Please connect your charger.'")
                        hasNotifiedLowBattery = true
                    }
                } else if (batteryCapacity >= 20 || batteryStatus === "Charging") {
                    hasNotifiedLowBattery = false
                }
            }
            
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
                id: dashboardContainer
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
                                
                                MouseArea {
                                    anchors.fill: parent
                                    anchors.margins: -8
                                    acceptedButtons: Qt.LeftButton | Qt.RightButton
                                    hoverEnabled: true
                                    cursorShape: Qt.PointingHandCursor
                                    
                                    onPressed: (mouse) => {
                                        var app = modelData
                                        if (mouse.button === Qt.LeftButton) {
                                            Hyprland.dispatch("exec /home/zoro/.config/quickshell/scripts/operate_app.sh focus " + app)
                                        } else if (mouse.button === Qt.RightButton) {
                                            Hyprland.dispatch("exec /home/zoro/.config/quickshell/scripts/operate_app.sh close " + app)
                                        }
                                    }
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
    
    /*
    // 3. Side Drawer Window for Thunderbird Mails
    Variants {
        model: Quickshell.screens
        
        PanelWindow {
            id: mailDrawerWindow
            required property var modelData
            screen: modelData
            visible: true
            
            WlrLayershell.namespace: "quickshell:mail_drawer"
            WlrLayershell.layer: WlrLayer.Top
            color: "transparent"
            anchors { top: true; bottom: true; left: true }
            
            // Set implicitWidth to animate when expanded or collapsed
            implicitWidth: isExpanded ? 340 : 40
            
            Behavior on implicitWidth {
                NumberAnimation { duration: 300; easing.type: Easing.OutQuint }
            }
            
            // Mask to ensure clicks pass through outside the drawer area
            mask: Region {
                item: drawerContainer
            }
            
            // Properties & States
            property bool isExpanded: false
            property var latestMails: []
            
            // Fetch mails every 15 seconds
            Timer {
                id: mailTimer
                interval: 15000
                running: true
                repeat: true
                triggeredOnStart: true
                onTriggered: {
                    mailProcess.running = true
                }
            }
            
            Process {
                id: mailProcess
                command: ["/home/zoro/.config/quickshell/scripts/get_latest_mails.py"]
                stdout: SplitParser {
                    onRead: (data) => {
                        try {
                            var obj = JSON.parse(data)
                            mailDrawerWindow.latestMails = obj
                        } catch(e) {
                            console.log("Error parsing mail JSON: " + e)
                        }
                    }
                }
            }
            
            Rectangle {
                id: drawerContainer
                anchors.fill: parent
                color: Qt.rgba(0.04, 0.04, 0.06, 0.92) // Deep premium glassmorphic dark
                border.width: 1.5
                border.color: Qt.rgba(1, 1, 1, 0.08)
                
                // Toggle Button (always visible on the right edge of the window)
                Rectangle {
                    id: toggleButton
                    anchors.right: parent.right
                    anchors.verticalCenter: parent.verticalCenter
                    width: 32
                    height: 80
                    radius: 8
                    color: Qt.rgba(0.12, 0.12, 0.16, 0.8)
                    border.width: 1
                    border.color: Qt.rgba(1, 1, 1, 0.1)
                    
                    Text {
                        anchors.centerIn: parent
                        font.pixelSize: 18
                        font.family: "JetBrainsMono Nerd Font"
                        color: "#ffffff"
                        text: mailDrawerWindow.isExpanded ? "" : ""
                    }
                    
                    MouseArea {
                        anchors.fill: parent
                        cursorShape: Qt.PointingHandCursor
                        hoverEnabled: true
                        onClicked: {
                            mailDrawerWindow.isExpanded = !mailDrawerWindow.isExpanded
                        }
                    }
                }
                
                // Main Mail Content (visible only when expanded)
                Item {
                    id: mailContent
                    anchors.fill: parent
                    anchors.rightMargin: 36 // leave space for toggle button
                    anchors.leftMargin: 20
                    anchors.topMargin: 40
                    anchors.bottomMargin: 20
                    visible: mailDrawerWindow.isExpanded || mailDrawerWindow.implicitWidth > 100
                    opacity: mailDrawerWindow.isExpanded ? 1.0 : 0.0
                    
                    Behavior on opacity {
                        NumberAnimation { duration: 150 }
                    }
                    
                    Column {
                        width: parent.width
                        spacing: 18
                        
                        Row {
                            spacing: 12
                            
                            Text {
                                font.pixelSize: 22
                                font.family: "JetBrainsMono Nerd Font"
                                color: "#00e676"
                                text: "󰇮"
                            }
                            
                            Text {
                                font.pixelSize: 18
                                font.family: "Outfit, Inter, Roboto, sans-serif"
                                font.weight: Font.Bold
                                color: "#ffffff"
                                text: "Thunderbird Inbox"
                            }
                        }
                        
                        Rectangle {
                            width: parent.width
                            height: 1
                            color: Qt.rgba(1, 1, 1, 0.1)
                        }
                        
                        // Scrollable list of mails
                        Column {
                            width: parent.width
                            spacing: 12
                            
                            Repeater {
                                model: mailDrawerWindow.latestMails
                                
                                Rectangle {
                                    width: parent.width
                                    height: 64
                                    radius: 10
                                    color: Qt.rgba(1, 1, 1, 0.03)
                                    border.width: 1
                                    border.color: Qt.rgba(1, 1, 1, 0.05)
                                    
                                    Column {
                                        anchors.fill: parent
                                        anchors.margins: 10
                                        spacing: 4
                                        
                                        Row {
                                            width: parent.width
                                            
                                            Text {
                                                width: parent.width - 60
                                                font.pixelSize: 13
                                                font.family: "Outfit, Inter, Roboto, sans-serif"
                                                font.weight: Font.Bold
                                                color: "#ffffff"
                                                elide: Text.ElideRight
                                                text: modelData.author
                                            }
                                            
                                            Text {
                                                width: 60
                                                font.pixelSize: 10
                                                font.family: "Outfit, Inter, Roboto, sans-serif"
                                                color: Qt.rgba(1, 1, 1, 0.4)
                                                horizontalAlignment: Text.AlignRight
                                                text: {
                                                    var diff = Math.floor(new Date().getTime() / 1000) - modelData.time
                                                    if (diff < 60) return "Just now"
                                                    if (diff < 3600) return Math.floor(diff / 60) + "m ago"
                                                    if (diff < 86400) return Math.floor(diff / 3600) + "h ago"
                                                    return Math.floor(diff / 86400) + "d ago"
                                                }
                                            }
                                        }
                                        
                                        Text {
                                            width: parent.width
                                            font.pixelSize: 12
                                            font.family: "Outfit, Inter, Roboto, sans-serif"
                                            color: Qt.rgba(1, 1, 1, 0.6)
                                            elide: Text.ElideRight
                                            text: modelData.subject
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
    }
    */
}
