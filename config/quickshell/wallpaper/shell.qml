import QtQuick
import Quickshell
import Quickshell.Wayland

ShellRoot {
    Variants {
        model: Quickshell.screens
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
                    // Time format: hh:mm
                    var hours = d.getHours()
                    var minutes = d.getMinutes()
                    if (hours < 10) hours = "0" + hours
                    if (minutes < 10) minutes = "0" + minutes
                    clockText.text = hours + ":" + minutes
                    
                    // Date format: DayName, MonthName DayNum
                    var days = ["Sunday", "Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday"]
                    var months = ["January", "February", "March", "April", "May", "June", "July", "August", "September", "October", "November", "December"]
                    dateText.text = days[d.getDay()] + ", " + months[d.getMonth()] + " " + d.getDate()
                }
            }
        }
    }
}
